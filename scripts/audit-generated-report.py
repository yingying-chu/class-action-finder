#!/usr/bin/env python3
"""Audit a generated Class Action Finder report without printing personal data."""

from __future__ import annotations

import re
import sys
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse


REQUIRED_IDS = {
    "action-queue",
    "purchase-matches",
    "active",
    "watching",
    "expired",
    "filed",
    "paid",
    "security",
}
HERO_WORD_LIMIT = 220


class Node:
    def __init__(self, tag: str, attrs=(), parent: "Node | None" = None):
        self.tag = tag
        self.attrs = dict(attrs)
        self.parent = parent
        self.children: list[Node] = []
        self.direct_text: list[str] = []

    @property
    def classes(self) -> set[str]:
        return set(self.attrs.get("class", "").split())

    def descendants(self):
        for child in self.children:
            yield child
            yield from child.descendants()

    def visible_text(self) -> str:
        if self.tag in {"script", "style"}:
            return ""
        return " ".join(self.direct_text + [child.visible_text() for child in self.children])


class ReportParser(HTMLParser):
    void_tags = {
        "area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "param", "source", "track", "wbr",
    }

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.root = Node("document")
        self.stack = [self.root]

    def handle_starttag(self, tag, attrs):
        node = Node(tag.lower(), attrs, self.stack[-1])
        self.stack[-1].children.append(node)
        if node.tag not in self.void_tags:
            self.stack.append(node)

    def handle_startendtag(self, tag, attrs):
        node = Node(tag.lower(), attrs, self.stack[-1])
        self.stack[-1].children.append(node)

    def handle_endtag(self, tag):
        tag = tag.lower()
        for index in range(len(self.stack) - 1, 0, -1):
            if self.stack[index].tag == tag:
                self.stack = self.stack[:index]
                return

    def handle_data(self, data):
        if data.strip():
            self.stack[-1].direct_text.append(data.strip())


def section_headings(section: Node | None) -> set[str]:
    if section is None:
        return set()
    headings = set()
    for node in section.descendants():
        if node.tag == "h3":
            value = " ".join(node.visible_text().lower().split())
            if value:
                headings.add(value)
    return headings


def has_ancestor_class(node: Node, class_name: str, stop: Node) -> bool:
    current: Node | None = node
    while current is not None:
        if class_name in current.classes:
            return True
        if current is stop:
            break
        current = current.parent
    return False


def audit(path: Path) -> list[str]:
    parser = ReportParser()
    parser.feed(path.read_text(encoding="utf-8"))
    nodes = list(parser.root.descendants())
    errors: list[str] = []

    if any(node.tag == "script" for node in nodes):
        errors.append("Report contains a script element.")
    if any(any(name.lower().startswith("on") for name in node.attrs) for node in nodes):
        errors.append("Report contains an inline event handler.")

    policies = [
        node.attrs.get("content", "")
        for node in nodes
        if node.tag == "meta"
        and node.attrs.get("http-equiv", "").lower() == "content-security-policy"
    ]
    if not policies or not any("default-src 'none'" in value and "form-action 'none'" in value for value in policies):
        errors.append("Report is missing the required restrictive CSP.")

    ids = [node.attrs["id"] for node in nodes if node.attrs.get("id")]
    id_counts = Counter(ids)
    missing_ids = sorted(REQUIRED_IDS - set(ids))
    if missing_ids:
        errors.append("Report is missing one or more required semantic anchors.")
    if any(re.fullmatch(r"sec[1-5]", value, re.IGNORECASE) for value in ids):
        errors.append("Report uses a positional sec1-sec5 anchor.")
    if any(count > 1 for count in id_counts.values()):
        errors.append("Report contains a duplicate HTML id.")

    for node in nodes:
        if node.tag != "a":
            continue
        href = node.attrs.get("href", "")
        if href.startswith("#"):
            continue
        parsed = urlparse(href)
        if parsed.scheme != "https" or not parsed.netloc:
            errors.append("Report contains a non-HTTPS external link.")
            break
        rel = set(node.attrs.get("rel", "").lower().split())
        if not {"noopener", "noreferrer"} <= rel:
            errors.append("An external report link is missing noopener/noreferrer.")
            break

    hero = next((node for node in nodes if "hero" in node.classes), None)
    if hero is None:
        errors.append("Report is missing the hero region.")
    else:
        hero_words = re.findall(r"\b[\w'’.-]+\b", hero.visible_text())
        if len(hero_words) > HERO_WORD_LIMIT:
            errors.append("Hero exceeds the generated-report readability limit.")
        hero_values = [node for node in hero.descendants() if "hero-value" in node.classes]
        if len(hero_values) != 1:
            errors.append("Hero must contain exactly one hero-value element.")
        hero_text = hero.visible_text().lower()
        if re.search(r"total settlement|settlement (?:fund|pool)|closed without filing", hero_text):
            errors.append("Hero contains settlement-fund or closed-window money context.")
        for node in hero.descendants():
            if any(re.search(r"\$\s*\d", text) for text in node.direct_text):
                if not has_ancestor_class(node, "hero-value", hero):
                    errors.append("Hero contains currency outside hero-value.")
                    break

    sections = {node.attrs.get("id"): node for node in nodes if node.tag == "section"}
    active = sections.get("active") or sections.get("sec1")
    expired = sections.get("expired") or sections.get("sec3")
    filed = sections.get("filed") or sections.get("sec4")
    if section_headings(active) & section_headings(filed):
        errors.append("A claim card is duplicated between Active and Filed.")

    if expired is not None and re.search(
        r"\b(?:claim\s+id|your\s+id|pin)\b", expired.visible_text(), re.IGNORECASE
    ):
        errors.append("Expired contains a claim ID or PIN.")

    visible = parser.root.visible_text()
    if re.search(r"\b\d{1,3}%\s*(?:confidence|verified|likely|legitimate)", visible, re.IGNORECASE):
        errors.append("Report renders a legitimacy percentage.")
    if "not individually searched" in visible.lower() and re.search(
        r"complete coverage|\bcomplete\b", visible, re.IGNORECASE
    ):
        errors.append("A complete report contains a not-individually-searched bucket.")

    # --- navigation: one row, counted chips, Paid not a peer, back-to-top ---
    navs = [n for n in nodes if n.tag == "nav"]
    if len(navs) != 1:
        errors.append("Report must have exactly one navigation row.")
    if re.search(r"also in this report", visible, re.IGNORECASE):
        errors.append("Report contains a second navigation row.")

    nav_links = [
        n
        for nav in navs
        for n in nav.descendants()
        if n.tag == "a" and n.attrs.get("href", "").startswith("#")
    ]
    if any(n.attrs.get("href") == "#paid" for n in nav_links):
        errors.append("Paid was promoted to a top-level navigation chip.")
    # Look for a digit anywhere in the chip's own text rather than a specific
    # element, so a designer can mark up the count however they like.
    uncounted = [n for n in nav_links if not re.search(r"\d", n.visible_text())]
    if nav_links and uncounted:
        errors.append("A navigation chip is missing its count.")

    # Sections present in the document but unreachable from the navigation, unless
    # the report names them as empty in the trailing line.
    linked = {n.attrs["href"].lstrip("#") for n in nav_links if n.attrs.get("href")}
    nonempty_unlinked = []
    for section_id in REQUIRED_IDS:
        section = next((n for n in nodes if n.attrs.get("id") == section_id), None)
        if section is None or section_id in linked or section_id == "paid":
            continue
        if len(section.visible_text().split()) > 25:
            nonempty_unlinked.append(section_id)
    if nonempty_unlinked:
        errors.append("A section with content has no navigation entry.")

    if not any("back-to-top" in n.classes for n in nodes):
        errors.append("Report offers no back-to-top affordance.")
    if not any(n.attrs.get("id") == "top" for n in nodes):
        errors.append("Report has no #top anchor for back-to-top links.")

    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: audit-generated-report.py REPORT.html", file=sys.stderr)
        return 2
    report = Path(sys.argv[1])
    if not report.is_file():
        print("Report file not found.", file=sys.stderr)
        return 2
    errors = audit(report)
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print("Generated report audit passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

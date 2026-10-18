#!/usr/bin/env python3
"""Build the single-file Markdown edition of a skill.

Usage: build-single-file.py <skill-dir> <output.md>

Some assistants accept one pasted or attached file but cannot install a skill
folder. This edition keeps SKILL.md's frontmatter and body, then appends every
reference guide and the report logo so nothing the workflow reads is missing.
"""

import sys
from pathlib import Path

skill_dir = Path(sys.argv[1])
skill_md = (skill_dir / "SKILL.md").read_text(encoding="utf-8")
if not skill_md.startswith("---\n"):
    raise SystemExit("SKILL.md must start with YAML frontmatter")
end = skill_md.index("\n---\n", 4) + len("\n---\n")
frontmatter, body = skill_md[:end], skill_md[end:]

notice = (
    f"\n> **Single-file edition.** Generated from `skills/{skill_dir.name}/` by "
    "`scripts/package-skill.sh`; do not edit it by hand. Use it in assistants that "
    "accept one pasted or attached file instead of an installed skill folder. "
    "Wherever the instructions say to read `references/<name>.md` or "
    "`assets/logo-mark.svg`, use the matching appendix at the end of this file. "
    "Unless the assistant can write persistent local files, follow the hosted-runtime "
    "rules under **Runtime and paths**.\n"
)

parts = [frontmatter, notice, body.rstrip("\n") + "\n"]
for ref in sorted((skill_dir / "references").glob("*.md")):
    parts.append(f"\n---\n\n# Appendix: references/{ref.name}\n\n")
    parts.append(ref.read_text(encoding="utf-8").rstrip("\n") + "\n")
logo = (skill_dir / "assets" / "logo-mark.svg").read_text(encoding="utf-8")
parts.append("\n---\n\n# Appendix: assets/logo-mark.svg\n\n```svg\n")
parts.append(logo.rstrip("\n") + "\n```\n")

Path(sys.argv[2]).write_text("".join(parts), encoding="utf-8")

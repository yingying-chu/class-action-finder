#!/usr/bin/env bash
# Convenience wrapper for Codex and ChatGPT users of the portable package.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$REPO_ROOT/scripts/package-skill.sh"

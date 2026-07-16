#!/usr/bin/env bash
# Backward-compatible name retained for existing repository instructions.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$REPO_ROOT/scripts/package-skill.sh"

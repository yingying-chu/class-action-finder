# AGENTS.md

This repo contains a single portable skill for Claude, Codex, and ChatGPT in `skills/class-action-finder/`.

**[`CLAUDE.md`](CLAUDE.md) is the source of truth** for how the skill is structured — its two jobs, the reference files, the persistent claim record, generated-report handling, the provider-adaptive mail step, and the `dist/` packaging rule. All of it applies to Codex too; read it first, and keep it (not this file) authoritative so the two don't drift.

## Codex specifics

- **Install:** `./install.sh --codex` installs into Codex's global skills directory (`${CODEX_HOME:-$HOME/.codex}/skills/`) so it works across all projects. The default `./install.sh` targets Claude Code.
- **Invoke:** `$class-action-finder` on Codex, versus `/class-action-finder` on Claude Code.
- **Tracker file:** `${CODEX_HOME:-$HOME/.codex}/class-action-tracker.json`. Codex and Claude Code keep separate trackers; neither installer overwrites the other's.

See [README.md](README.md) for full setup instructions.

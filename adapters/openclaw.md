# OpenClaw Adapter

OpenClaw is supported directly by the `skills` CLI using the `openclaw` agent alias.

## Install

Project-local install:

```bash
npx skills add dmytri/shipshape --agent openclaw --skill '*'
```

Expected project layout:

```text
<project>/skills/shipshape/SKILL.md
<project>/skills/captain/SKILL.md
<project>/skills/qm/SKILL.md
<project>/skills/crew/SKILL.md
```

Global install:

```bash
npx skills add dmytri/shipshape --agent openclaw --global --skill '*'
```

The CLI installs global OpenClaw skills under `~/.openclaw/skills/`.

## Usage

Use the installed role skills by name:

- `shipshape` for workflow orientation.
- `captain` for human-facing discovery/specification.
- `qm` only in a fresh/cleared context for verification.
- `crew` for one failing implementation target.

OpenClaw skills run with full agent permissions, so review installed skill files before use.

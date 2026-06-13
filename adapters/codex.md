# Codex Adapter

Codex is supported directly by the `skills` CLI.

## Install

Project-local install:

```bash
npx skills add dmytri/shipshape --agent codex --skill '*'
```

Expected project layout:

```text
<project>/.agents/skills/shipshape/SKILL.md
<project>/.agents/skills/captain/SKILL.md
<project>/.agents/skills/qm/SKILL.md
<project>/.agents/skills/crew/SKILL.md
```

Global install:

```bash
npx skills add dmytri/shipshape --agent codex --global --skill '*'
```

The CLI installs global Codex skills under `~/.codex/skills/`.

## Usage

Use the installed skills by name:

- `shipshape` for workflow orientation.
- `captain` for human-facing discovery and specs.
- `qm` in a fresh/cleared session for verification and test coverage.
- `crew` for one failing implementation target.

Codex should follow the same Shipshape context firewall: do not run Quartermaster in a session that contains Captain/human discovery chat.

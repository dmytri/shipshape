# Goose Adapter

Goose is supported directly by the `skills` CLI using the `goose` agent alias.

## Install

Project-local install:

```bash
npx skills add dmytri/shipshape --agent goose --skill '*'
```

Expected project layout:

```text
<project>/.goose/skills/shipshape/SKILL.md
<project>/.goose/skills/captain/SKILL.md
<project>/.goose/skills/qm/SKILL.md
<project>/.goose/skills/crew/SKILL.md
```

Global install:

```bash
npx skills add dmytri/shipshape --agent goose --global --skill '*'
```

The CLI installs global Goose skills under `~/.config/goose/skills/`.

## Usage

Use the installed skills by name:

- `shipshape` for orientation.
- `captain` for discovery/specification.
- `qm` for fresh-context verification.
- `crew` for focused implementation.

If Goose does not expose skills as slash commands in your setup, invoke the skill by name in natural language.

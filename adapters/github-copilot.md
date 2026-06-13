# GitHub Copilot Adapter

GitHub Copilot agent skills are supported by the `skills` CLI using the `github-copilot` agent alias.

## Install

Project-local install:

```bash
npx skills add dmytri/shipshape --agent github-copilot --skill '*'
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
npx skills add dmytri/shipshape --agent github-copilot --global --skill '*'
```

The CLI installs global GitHub Copilot skills under `~/.copilot/skills/`.

## Usage

Use the installed skills by name in Copilot agent workflows:

- `shipshape` for orientation.
- `captain` for human-facing spec work.
- `qm` for fresh-context verification.
- `crew` for one failing target.

If Copilot does not expose skill names as slash entries in your environment, reference the skill name explicitly in the prompt.

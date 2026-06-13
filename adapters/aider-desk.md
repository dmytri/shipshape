# AiderDesk Adapter

AiderDesk is supported by the `skills` CLI using the `aider-desk` agent alias.

> Note: `aider` is not currently a valid `skills` CLI agent alias. Use `aider-desk` for AiderDesk, or use the generic/manual fallback for other Aider setups.

## Install

Project-local install:

```bash
npx skills add dmytri/shipshape --agent aider-desk --skill '*'
```

Expected project layout:

```text
<project>/.aider-desk/skills/shipshape/SKILL.md
<project>/.aider-desk/skills/captain/SKILL.md
<project>/.aider-desk/skills/qm/SKILL.md
<project>/.aider-desk/skills/crew/SKILL.md
```

Global install:

```bash
npx skills add dmytri/shipshape --agent aider-desk --global --skill '*'
```

The CLI installs global AiderDesk skills under `~/.aider-desk/skills/`.

## Usage

Use the installed role skills by name where AiderDesk exposes skills. For non-AiderDesk Aider workflows, use `agents/captain.md`, `agents/quartermaster.md`, and `agents/crew-mate.md` as manual prompts.

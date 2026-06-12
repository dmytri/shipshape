# Hermes Adapter

Hermes integration details are intentionally treated as runtime-specific. Shipshape works without relying on Hermes-specific features.

## Preferred skills.sh install

If your Hermes setup consumes `.agents/skills`, install all Shipshape skills into the project:

```bash
npx skills add dmytri/shipshape --skill '*'
```

This provides sibling skills:

```text
.agents/skills/shipshape/SKILL.md
.agents/skills/captain/SKILL.md
.agents/skills/qm/SKILL.md
.agents/skills/crew/SKILL.md
```

## Generic Adoption

If Hermes does not consume skills directly:

1. Put `AGENTS.md` from `templates/AGENTS.md` in the project root.
2. Configure project commands and directories.
3. Store role prompts from `agents/` in the repository.
4. Invoke agents with the matching role prompt.

## Role Mapping

- Human-facing planning session → `captain` skill or Captain prompt.
- Fresh/cleared test/harness/coverage session → `qm` skill or Quartermaster prompt. If Quartermaster detects Captain/human discovery context, it refuses to continue.
- Focused implementation session → `crew` skill or Crew Mate prompt.

## Dispatch

If Hermes supports spawning or routing to specialized agents, have Quartermaster dispatch Crew Mate tasks with one failing target each.

If Hermes does not support dispatch, run separate sessions manually or document that Quartermaster fallback is allowed.

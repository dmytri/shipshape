# Hermes Adapter

Hermes integration details are intentionally treated as runtime-specific. Shipshape works without relying on Hermes-specific features.

## Generic Adoption

1. Put `AGENTS.md` from `templates/AGENTS.md` in the project root.
2. Configure project commands and directories.
3. Store role prompts from `agents/` in the repository.
4. Invoke agents with the matching role prompt.

## Role Mapping

- Human-facing planning session → Captain.
- Fresh/cleared test/harness/coverage session → Quartermaster. If Quartermaster detects Captain/human discovery context, it refuses to continue.
- Focused implementation session → Crew Mate.

## Dispatch

If Hermes supports spawning or routing to specialized agents, have Quartermaster dispatch Crew Mate tasks with one failing target each.

If Hermes does not support dispatch, run separate sessions manually or document that Quartermaster fallback is allowed.

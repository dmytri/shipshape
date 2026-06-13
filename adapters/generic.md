# Generic Shipshape Adapter

Use this adapter for agents that do not have a dedicated `skills` CLI alias, do not expose installed skills directly, or need a plain repository-instructions fallback.

## Minimal project setup

1. Copy `templates/AGENTS.md` to the target project root as `AGENTS.md`.
2. Fill in the placeholders for spec directories, implementation directories, verification commands, handoff files, and assets policy.
3. Optionally copy `templates/HANDOVER.md` for durable current-state handoff.
4. Keep the portable role prompts available to the agent:
   - `agents/captain.md`
   - `agents/quartermaster.md`
   - `agents/crew-mate.md`
5. Start each session by loading or referencing the matching role prompt.

## Role mapping

| Work | Use |
|---|---|
| Human-facing discovery, specs, blockers, project instructions | Captain prompt or `captain` skill |
| Fresh-context tests, harnesses, fixtures, verification | Quartermaster prompt or `qm` skill |
| One failing implementation target | Crew Mate prompt or `crew` skill |

## Context firewall

When moving from Captain to Quartermaster, clear the conversation or start a fresh agent session. Quartermaster must use only committed specs, tests, instructions, and explicit durable handoff files. If it can see Captain/human discovery context, it must refuse and ask for a fresh/cleared session.

When Quartermaster finds a blocker, escalate back to Captain without clearing unless there is a separate reason to clear. Captain can use QM's concrete failure context to update durable specs and instructions.

## Commands and subagents

If the runtime supports custom commands, map command entrypoints from `commands/` to the runtime's command mechanism.

If the runtime supports subagents, register `agents/crew-mate.md` as the focused implementation subagent and have Quartermaster dispatch one failing target at a time.

If it does not support subagents, run Crew Mate sessions manually. If manual Crew sessions are impractical, document the Quartermaster implementation fallback in `HANDOVER.md` before allowing QM to implement after writing failing tests.

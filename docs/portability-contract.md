# Portability Contract

Shipshape is agent-runtime neutral.

## Required Agent Capabilities

At minimum, an agent should be able to:

- read repository files,
- write repository files,
- inspect test or verification output,
- follow role-specific instructions,
- report blockers clearly.

Optional capabilities:

- spawn subagents,
- define slash commands,
- load skills automatically,
- run shell commands,
- maintain per-role tool permissions.

## Runtime-Neutral Terms

| Shipshape term | Runtime-neutral meaning |
|---|---|
| Skill | Reusable instructions loaded by an agent |
| Command | A named prompt entrypoint |
| Subagent | A separate role-specialized agent session |
| Spec | Durable expected-behavior artifact |
| Verification | Tests, typechecks, linters, dry-runs, or equivalent checks |
| Blocker | A condition that requires spec/instruction clarification |

## Must Preserve

Any adapter must preserve these rules:

1. Captain is the only human-facing role.
2. Captain updates specs/instructions, not implementation.
3. QM writes tests/harness/coverage from committed specs.
4. Crew Mate implements minimal code for one failing target.
5. QM and Crew do not accept ad hoc product instructions.
6. Blockers return to Captain and are resolved in durable artifacts.
7. Work is derived from verification status.
8. Fresh sessions must be able to continue from repository files alone.
9. Quartermaster must be invoked in a fresh/cleared context after Captain; it must never inherit Captain chat context.

## May Adapt

Adapters may change:

- file locations,
- command names,
- test frameworks,
- spec formats,
- subagent mechanics,
- validation commands,
- handover naming.

## Dispatch Fallback

If the runtime cannot dispatch subagents, there are two valid options:

1. Start Crew Mate sessions manually for each failing target.
2. Allow Quartermaster fallback after it writes failing tests.

The fallback should be explicit in the handover or project instructions.

# Portability Contract

Shipshape is agent-runtime neutral and context-isolated. It can be adapted to Zed, Claude Code, Cursor, OpenCode, Hermes Agent, Codex, GitHub Copilot, OpenClaw, Goose, AiderDesk, Pi, and other coding-agent environments.

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
| Runtime command | A runtime-provided invocation mechanism, such as Pi slash commands |
| Subagent | A separate role-specialized agent session |
| Spec | Durable expected-behavior artifact |
| Verification | Tests, typechecks, linters, dry-runs, or equivalent checks |
| Blocker | A condition that requires spec/instruction clarification |

## Must Preserve

Any adapter must preserve these rules:

1. Captain is the only human-facing role.
2. Captain updates specs/instructions, not implementation.
3. QM writes tests/harness/coverage from durable specs.
4. Crew Mate implements minimal code for one failing target.
5. QM and Crew derive product behavior from durable artifacts, not ad hoc chat instructions.
6. Blockers load Captain and are resolved in durable artifacts.
7. Work is derived from verification status.
8. Fresh sessions must be able to continue from repository files alone.
9. Quartermaster must run in a fresh/cleared context after Captain and must refuse if it can detect Captain/human discovery context in the current session.
10. After QM starts clean, QM, Crew, Bosun, and Captain may transition by loading the next role skill in the same artifact-grounded session.
11. Bosun stops at a clean local commit boundary; Captain handles outbound decisions.

## May Adapt

Adapters may change:

- file locations,
- command names,
- test frameworks,
- spec formats,
- subagent mechanics,
- validation commands,
- handover naming.

## Role Loading

Subagents are optional. If the runtime cannot dispatch subagents, the active agent loads the next role skill directly:

```text
QM -> Crew -> QM -> Bosun -> Captain
```

Only Captain → QM requires a cleared/fresh context.

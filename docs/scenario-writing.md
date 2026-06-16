# Scenario-writing guide

How to write `.feature` scenarios and steps for Shipshape projects. Draws on standard BDD practice (specific, declarative, independent) plus Shipshape's hard rule:

> **Every scenario describes a real feature we can test explicitly** — a named input/command and a concrete, checkable outcome. If you cannot write the assertion as a check on observable output or state, it is not a scenario.

## Principles

- **One behavior per scenario.** Test a single thing; keep it ~3–7 steps. Split a scenario that asserts many unrelated things.
- **Tie it to a real outcome.** Each scenario verifies a result the user (the customer's agent, or the customer) actually cares about — a job done, not an internal step performed.
- **YAGNI — specify only what the current iteration needs.** Don't write scenarios for flags, capabilities, edge cases, or error paths the MVP doesn't require. The coverage method below surfaces *candidates*; keep the ones that protect the launch bar or a real user job, and defer the rest to the iteration phase. An unneeded spec is waste and a drift risk, exactly like a missing one.
- **Declarative — assert the outcome, not the mechanism.** Assert WHAT is observable (a service exists and is reported, a key is written, the output carries a field), not HOW the tool did it internally (which function, which exact call). *Exception:* when the request itself is the contract under test — a host allowlist, or a `--dry-run` that must show the real host/path it would call — then naming the request IS the outcome.
- **Independent.** No scenario depends on another having run first.

## Concrete steps, end to end

- **`Given`** = a concrete precondition/state: a real flag, a file present, a credential state. Not a vague situation ("the setup flow reaches payment configuration").
- **`When`** = a concrete action or event: running a **named** command (e.g. `deploy --env production --json`) or a specific input arriving. Never a circular restatement that triggers nothing ("when the output describes the action", "when the agent handles setup", "when the tool prepares to perform the action").
- **`Then`** = a falsifiable assertion on an observable: an output field/value, a stable error `code`, a check `status`, a written file or `.env` key, a host contacted, a process exit code.

## Anti-patterns (reject these)

- **Faux / placeholder / design-note steps.** A step that cannot be executed and asserted is not a step. No `pending` stubs standing in for coverage.
- **Abstract subject.** Never "any command", "a create subcommand", "a side-effecting command", "the primary guided command", "a collision", "a step would overwrite". For a parametric contract, use a `Scenario Outline` over real cases.
- **Asserts the actor, not the tool.** Never "the customer's agent decides", "the agent should ask/tell/pause/run", or what a human chooses. Assert the tool's observable output/artifacts.
- **Hedge words** that make an assertion unfalsifiable: "where possible/appropriate/feasible/available", "as needed", "when appropriate", "concise", "clearly", "blindly", "unnecessarily", "reviewable", "understandable", "reliable". Replace each with the concrete observable.
- **Behavior buried in `Rule:` prose.** Testable contracts go in scenarios. `Rule:` blocks carry only non-executable context — rationale, research notes, cross-references.

## Structure & coverage

- **Group scenarios under business `Rule:` blocks.** Happy path first, then edge/negative cases added systematically (errors, collisions, missing credentials).
- **Tag by tier:** `@logic` (pure local, no accounts), `@sandbox` (real accounts), `@eval` (opt-in affordance eval). See `AGENTS.md` for tier definitions and the sandbox harness rules.
- **Verify cross-cutting invariants at each site.** Idempotency (safe re-run, no duplicates, reports detected state), risk context, no-fabrication, and the output envelope are asserted where each concrete command exercises them — not delegated to one abstract feature.
- **Prefer real exercise over mocks.** A mock only injects a condition a sandbox cannot produce; never to replace normal-path coverage.
- **Affordances are testable.** Agent-instruction/skill behavior is asserted at the affordance level (documented commands invoked, documented artifacts appeared) with no model credentials — write it as steps, not prose.

## Finding the scenarios you're missing (coverage)

Happy-path-only thinking misses the scenarios that matter most. For each feature, derive scenarios from the **forces** acting on the user (adapted from JTBD→BDD):

| Force | Question | This surfaces… |
|---|---|---|
| **Push** | What frustration drove them here? | the end-to-end happy path works |
| **Pull** | What measurable outcome do they want? | the launch-bar assertions (deployed URL serves expected output, service reaches the expected state) |
| **Anxiety** | What could the new tool break? | the **safety nets**: re-run is idempotent (no duplicates), collisions pause instead of overwriting, honest errors (no fabricated success), harmless against real state |
| **Habit** | What old workflow resists adoption? | the agent can still run steps manually, and the tool recognizes externally-produced work rather than redoing it |

Then walk the **job map** and ask "what could go wrong at this step that we haven't tested?" — missing creds (Define), stale/absent inputs (Locate), misconfigured env (Prepare), false-positive validation (Confirm → no-fabrication), interruption (Execute → resumable), misleading success (Monitor → doctor probe), an upgrade that regresses (Modify → plan-only), failed teardown/cleanup (Conclude). Each gap is a candidate edge-case scenario.

**Apply YAGNI to the candidates.** This method surfaces more than the current iteration needs. Keep a gap only if it protects the launch bar or a real user job in the current iteration; defer the rest to the iteration phase rather than specifying speculative edge cases now.

Use **concrete data** in every scenario — real flag values, real `.env` keys, real hostnames — never placeholders.

## `@property` scenarios (invariants)

Some contracts are ongoing qualities that hold across *every* command, not a single event — e.g. a tool's request code only ever contacts first-party hosts, and no command ever fabricates success. Write these as a single scenario asserting the invariant over the whole surface, and tag it `@property` (in addition to its tier tag). Prefer one clear invariant scenario over restating the rule in every feature.

`@property` covers two kinds of invariants:

- **Agent-behavior invariants** — things a role should always do or never do (e.g. "Captain never writes production code", "Crew changes only the minimum"). These test that the agent follows its skill instructions.
- **Runtime-enforcement invariants** — things a runtime should enforce regardless of agent behavior (e.g. "QM context.excludes contains CAPTAIN.md", "Crew permissions.write does not contain 'specs'"). These test that the runtime actually blocks violations.

Both kinds are falsifiable assertions and belong in `.feature` files as `@property` scenarios. The testability principle is the same regardless of whether the subject is agent behavior or runtime enforcement — if you can write a falsifiable assertion, you can write a scenario.

## Positive observables over prohibitions

"Shall not" prose is unenforced. Express architecture and security constraints as positive falsifiable observables:

- Instead of "QM shall not read CAPTAIN.md", write "QM context.excludes contains CAPTAIN.md".
- Instead of "Captain shall not write production code", write "Captain permissions.write does not contain production".
- Instead of "Crew shall not rewrite tests", write "Crew permissions.write does not contain test files".

This makes the constraint testable and gives the runtime something concrete to assert.

## cycle.json

For directed work (refactors, conformance seeding, dependent scenarios), Captain writes `cycle.json` to scope QM's worklist to specific scenarios in pass order. See `docs/cycle.json.md` for schema and usage.

Scenarios referenced in `cycle.json` follow the same writing rules as any other scenario. The `cycle.json` mechanism does not change how scenarios are written — only which ones QM processes.

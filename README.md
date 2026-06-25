# Shipshape

[![skills.sh](https://skills.sh/b/dmytri/shipshape)](https://skills.sh/dmytri/shipshape)

Shipshape is a portable skill set for coding agents that turns product intent into durable Cucumber specs, derives work from failing verification, and keeps agent roles isolated so context does not leak into implementation.

**Specifications are durable. Code and verification are disposable. Agents are replaceable.**

## Install

```bash
npx skills add dmytri/shipshape --skill '*'
```

This installs all five skills: `/shipshape`, `/captain`, `/qm`, `/crew`, and `/bosun`. Start with Captain.

## Why Shipshape exists

Plain agent coding often traps product intent in chat. Memory-bank workflows can preserve too much stale context. Markdown-heavy spec-driven workflows can turn generated plans and task lists into false progress. Agents drift when the same context contains discovery, planning, tests, and code. Old specs, stale tests, and orphaned code pollute future work.

Shipshape answers those failure modes with a small, current-state workflow:

- Product behaviour lives in `.feature` specs.
- Work comes from undefined, unimplemented, or failing verification.
- Roles have strict custody over specs, verification, implementation, and hygiene.
- Context is cleared between Captain and Quartermaster.
- Bosun removes stale artifacts.
- `watchbill.json` selects and orders discovered work only; it does not create work.

## What Shipshape is

Shipshape is a disciplined workflow for keeping product intent durable, agent context disposable, and progress tied to verification.

It uses Cucumber-native specifications as the durable product contract. It treats production code and verification as rebuildable from that contract. It separates human-facing discovery, verification design, implementation, and cleanup into roles with narrow write scopes.

## What Shipshape is not

Shipshape is not:

- an IDE,
- a memory bank,
- a backlog format,
- a task-list generator,
- a project constitution,
- a code generator,
- a replacement for Cucumber,
- a runtime enforcement system by itself.

Shipshape is the portable skill layer. Enforcing runtimes can make the rules mechanical.

## What is authoritative?

Shipshape keeps the authoritative surface small:

- `.feature` files define binding product behaviour.
- `assets/**` are Captain-owned editable artifacts: product material, examples, fixtures, content, media, or other support material. Assets are not instructions, backlog, rationale, project memory, or hidden requirements.
- `AGENTS.md` or equivalent tooling config defines project tooling and agent configuration.
- `CAPTAIN.md`, if present, contains Captain-only non-binding notes.
- `watchbill.json` selects and orders verification-discovered work only.
- Trace comments explain why code or support artifacts exist; they do not define product intent.
- Git history preserves history. Current files describe current design.

If asset content must be protected as behaviour, specify that behaviour in a `.feature` scenario.

## Workflow and roles

```text
Captain → clear context → QM → Crew → QM → Bosun → Captain
```

- Captain discovers intent and writes current `.feature` specs, assets, `CAPTAIN.md`, and optional `watchbill.json`.
- Quartermaster starts from fresh context and turns specs into executable verification.
- Crew changes production code for one failing verification target.
- Bosun removes stale artifacts, rechecks verification, and commits locally.

Only Captain talks to the user. Internal roles report through durable artifacts, verification output, and role hand-offs.

## Verification is progress

In Shipshape, progress is not a checked box in markdown. Progress is fewer undefined, unimplemented, or failing verification targets.

- Verification discovers the worklist.
- `watchbill.json` can select and order discovered scenario work.
- `watchbill.json` cannot create work that verification cannot discover.
- Passing checks are evidence, not proof.
- Reports must distinguish fresh results from cache-backed results.

## Watchbill

Captain may write `watchbill.json` to direct a subset of verification-discoverable work. Watchbill is scenario-level only and uses scenario references in this form:

```text
<spec>.feature:<Scenario Name>
```

Watch objects such as `watch1` and `watch2` are ordering groups only. QM processes all watches in order unless verification, product intent, environment, or tooling blocks. If Watchbill and verification disagree, verification wins.

## Traceability

Shipshape uses lightweight trace comments when they make ownership, deletion, or behaviour mapping clearer:

```ts
// Shipshape implements: features/checkout/card-payment.feature:Card payment is authorized
// Step: Then the payment is authorized
```

- `implements` links production code to scenario behaviour.
- `supports` links helpers, fixtures, generated files, or assets to scenario behaviour.
- `verifies` is optional when a test-to-scenario mapping is not already clear.
- The canonical target is `<spec>.feature:<Scenario Name>`.
- Optional `Step:` detail is human-readable extra context.

Trace links explain why artifacts exist. They do not create work, replace verification discovery, or define product intent.

## Comparison with related approaches

| Approach | What it does | Shipshape difference |
|---|---|---|
| Kiro-style SDD | Requirements, design, task lists, IDE execution | Shipshape rejects task-list progress; verification discovers work. |
| Spec Kit-style SDD | Constitution, plans, tasks, generated markdown workflow | Shipshape keeps the authoritative surface small and current-state only. |
| Tessl-style spec/code linking | Specs tied to tests/code, sometimes toward code generation | Shipshape uses trace comments but remains Cucumber-native and not codegen-first. |
| Memory banks | Preserve context across sessions | Shipshape discards chat context and keeps only durable artifacts. |
| Plain agent coding | Agent writes from prompt context | Shipshape preserves intent and makes progress auditable. |

## Enforcement and portability

Shipshape skills work anywhere a coding agent can read repository files and follow role instructions. The workflow is portable by design: Cucumber specs, verification output, trace comments, and git history carry the durable state.

Skill-only agents follow the rules by explicit discipline. Enforcing runtimes can turn the same rules into mechanical checks.

## Origin

Shipshape was extracted from work done at [Saleor](https://saleor.io), an open-source, headless GraphQL e-commerce platform.

For an agent-oriented way to start Saleor storefront work, see [Jolly](https://jolly.cool). Jolly is experimental and should be treated as a preview.

## License

MIT

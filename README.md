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

Shipshape is deliberately narrow. It is most opinionated about Cucumber-native executable specs, context-isolated roles, and verification-discovered work.

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

Shipshape separates agent work by custody and context. Each role sees only the context needed for its job and writes only its own layer.

| Role | Owns | Does not own |
|---|---|---|
| Captain | Human-facing discovery, `.feature` specs, assets, `CAPTAIN.md`, optional `watchbill.json` | Production code, verification, hidden implementation instructions |
| Quartermaster | Verification design, tests, fixtures, step definitions, harness support | Product intent, production code, Captain notes |
| Crew | The smallest production-code change for one failing verification target | Specs, tests, broad refactors, product interpretation |
| Bosun | Hygiene, stale artifact removal, verification recheck, local commit custody | New behaviour, product decisions, outbound actions |

Only Captain talks to the user. QM, Crew, and Bosun are internal roles. They report through verification output, repository changes, and role hand-offs.

The most important boundary is Captain → QM. Captain may use human conversation to discover intent, but QM starts from clean context and reads only durable repository artifacts. This prevents discovery chat, rationale, and abandoned ideas from leaking into tests or implementation.

Role flow:

1. Captain captures product behaviour in current `.feature` specs.
2. Context clears.
3. QM derives executable verification from the specs.
4. Crew makes one focused production change for one failing target.
5. QM reruns verification and may dispatch more Crew work.
6. Bosun removes stale artifacts, checks hygiene, verifies, and commits locally.
7. Captain reports back to the user and handles outbound decisions.

## Verification is progress

In Shipshape, progress is not a checked box in markdown. Progress is fewer undefined, unimplemented, or failing verification targets.

- Verification discovers the worklist.
- `watchbill.json` can select and order discovered scenario work.
- `watchbill.json` cannot create work that verification cannot discover.
- Passing checks are evidence, not proof.
- QM should prefer Watchbill-selected and targeted focused runs over full tier runs when they are enough to advance the current target.
- Full tier runs are boundary checks, not the default inner loop.
- When no discovered work remains, Captain must offer to run the entire test suite across all tiers.
- Reports must distinguish fresh results from cache-backed results.

## Watchbill

Captain SHOULD write `watchbill.json` to direct a subset of verification-discoverable work when QM or Crew work should be focused. Watchbill helps QM avoid wasteful full-tier loops by selecting the current scenario set. Watchbill is scenario-level only and uses scenario references in this form:

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

## Related approaches

Shipshape combines four ideas: role custody, context aversion, verification as progress, and Cucumber-native traceability. These ideas overlap with other SDD and agent-workflow systems, but Shipshape uses them differently.

### Spec-driven development tools

[Kiro](https://kiro.dev), [Spec Kit](https://github.com/github/spec-kit), [OpenSpec](https://github.com/Fission-AI/OpenSpec), and [Tessl](https://tessl.io) explore structured specification before implementation. Shipshape shares the spec-first instinct, but rejects generated task-list progress. Product behaviour belongs in current Cucumber specs, and implementation work is driven by verification state.

Kiro, Spec Kit, and OpenSpec use requirements, plans, proposals, tasks, or implementation phases to organise work. Shipshape uses current Cucumber specs as the behaviour contract and verification state as the work signal.

Shipshape is not codegen-first. Tessl explores stronger links between specs, tests, and generated code. Shipshape keeps code and verification disposable from specs, but production code still changes through focused failing verification targets.

For background, see Birgitta Böckeler’s article on SDD tools on Martin Fowler’s site: [Exploring Gen AI: Spec-Driven Development Tools](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html).

### Role-workflow and agent-team systems

[BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD), [Superpowers](https://github.com/obra/superpowers), [Paperclip](https://paperclip.ing), [Fusion](https://runfusion.ai), companies.sh, [Gastown](https://github.com/gastownhall/gastown), and similar systems use agents, roles, teams, or named workflow positions to organise work.

BMAD and Superpowers use role or workflow structure to guide agentic software work. Paperclip, Fusion, companies.sh, and Gastown go further toward agent teams, organisations, or named agent societies. Shipshape also uses roles, but the roles are not an organisation simulation or a cast of specialist personas. They are custody boundaries.

Captain owns human discovery and specs. QM owns verification. Crew owns one production-code target. Bosun owns hygiene, verification recheck, and local commit custody.

BMAD, Superpowers, Paperclip, Fusion, companies.sh, and Gastown use roles to model people, teams, processes, organisations, workflows, or agent societies. Shipshape uses roles to prevent context leakage and write-scope drift.

### Context and authority

Kiro, Spec Kit, OpenSpec, and Tessl structure more context through specs, plans, proposals, tasks, generated artifacts, or spec/code links. Shipshape tries to preserve less context, not more.

Chat is discarded. Product behaviour lives in current `.feature` files. Assets are Captain-owned editable material, not hidden requirements. Tooling belongs in `AGENTS.md`. Directed work selection belongs in `watchbill.json`. History belongs in git.

This keeps the authoritative surface small and current. It also prevents discovery chat, rationale, abandoned ideas, and stale plans from leaking into verification or code.

### Verification as progress

Kiro, Spec Kit, and OpenSpec organise progress through task lists, proposal states, implementation phases, or generated work plans. BMAD, Superpowers, Paperclip, Fusion, companies.sh, and Gastown may organise progress through agent reports, tickets, roles, process state, or team workflow.

Shipshape treats those as weak evidence.

In Shipshape, progress is tested. Progress means fewer undefined, unimplemented, or failing scenario targets. A claimed task completion is not progress unless verification can observe it.

This does not mean Kiro, Spec Kit, OpenSpec, Tessl, BMAD, Superpowers, Paperclip, Fusion, companies.sh, or Gastown lack tests. The distinction is that Shipshape makes verification status the progress measure, not a generated worklist, proposal state, or agent status report.

### Traceability without codegen

Tessl explores stronger links between specs, tests, and generated code. Kiro, Spec Kit, and OpenSpec also keep structured links between requirements, plans, tasks, and implementation work. Shipshape uses lighter Cucumber-native trace comments instead.

Trace links explain why code or support artifacts exist, but they do not define product intent, create work, or replace verification discovery.

## Enforcement and portability

Shipshape skills work anywhere a coding agent can read repository files and follow role instructions. The workflow is portable by design: Cucumber specs, verification output, trace comments, and git history carry the durable state.

Skill-only agents follow the rules by explicit discipline. Enforcing runtimes can turn the same rules into mechanical checks.

## Origin

Shipshape was extracted from work done at [Saleor](https://saleor.io), an open-source, headless GraphQL e-commerce platform.

For an agent-oriented way to start Saleor storefront work, see [Jolly](https://jolly.cool). Jolly is experimental and should be treated as a preview.

## License

BSD Zero Clause License

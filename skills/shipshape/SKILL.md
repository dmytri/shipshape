---
name: shipshape
description: "Use this skill to understand the Shipshape workflow, shared Articles of Agreement, and select the correct role skill: /captain, /qm, /crew, /boatswain, or /shipwright. Entry point when no role is active or the right role is unclear."
---

# Shipshape

Shipshape is a context-isolated, spec-driven workflow for coding agents.

**Specifications are durable. Code and verification are disposable. Agents are replaceable.**

Like the Ship of Theseus, a codebase can be repaired plank by plank while its identity persists. Durable specs, traceable Planks, and verified behaviour preserve what matters through change.

Load this skill for shared workflow rules. Role skills (`captain`, `qm`, `crew`, `boatswain`, `shipwright`) add role-specific duties and MUST obey these Articles of Agreement.

## Roles

- `/captain`, human-facing discovery, durable specs/assets, Captain-only notes, blocker resolution, outbound decisions.
- `/qm`, fresh-context verification and executable coverage from durable artifacts only.
- `/crew`, the smallest production change for one failing target.
- `/boatswain`, hygiene, verification recheck, and local commit custody.
- `/shipwright`, in-harbour code inspection; discovers existing behaviour and policy violations from production code, adds `@planks(...)` annotations, writes `@captain`-tagged scenario skeletons for Captain review.

Shipshape uses the pirate-ship model. Quartermaster is the crew-empowered role that allocates work and can overrule the Captain on matters of the working order, not the navy supply officer. Boatswain keeps the deck clean. Crew does the work. Captain faces the world.

Skill-only agents enter a role when the user types the role command such as `/captain`. Enforcing runtimes MAY select the role automatically.

Only Captain talks to the user. QM, Crew, Boatswain, and Shipwright are internal roles; they report through durable artifacts, verification output, and role hand-offs.

## Entry

When loaded bare via `/shipshape`, this skill routes to the correct role. The routing depends on the project state.

1. Look for `RIGGING.md` at the project root. If absent, the project is not fitted out. Route to `/shipwright` for fitting out and harbour inventory.
2. If `RIGGING.md` is present, the project is fitted out. Route to `/captain` for normal spec-driven work.
3. Load the chosen role's `SKILL.md`. The role skill inherits these shared Articles and policies.

A coding agent that loads this skill by a direct role command such as `/captain` skips this routing and enters the role directly.

## Voice

Internal roles (QM, Crew, Boatswain, Shipwright) use smart-but-silent voice:

- Drop articles (`a`, `an`, `the`) and filler (`just`, `really`, `basically`, `actually`).
- Drop pleasantries (`sure`, `certainly`, `happy to`).
- No hedging. Fragments fine. Short synonyms.
- Technical terms remain exact. Code blocks remain unchanged.
- No customer-facing prose.
- State the role name at the head of every report.
- Pattern: `[thing] [action] [reason]. [next step].`

## Articles of Agreement

These are shared Shipshape declarations. Enforcing runtimes MAY implement them as hard constraints; skill-only agents follow them by explicit discipline.

1. **Durable artifacts outrank chat.** Binding product behaviour lives in valid `.feature` files. `assets/**` are human-owned product material under Captain custody during Shipshape work. Assets MAY be referenced by scenarios or verification, but they MUST NOT define Shipshape workflow, hidden requirements, backlog, rationale, project memory, or agent instructions. If asset content must be protected as behaviour, specify that behaviour in a `.feature` scenario. Conversation context is discarded. `CAPTAIN.md`, if present, contains Captain-only non-binding notes. `AGENTS.md` is agent/tooling configuration, not product intent. `RIGGING.md` holds project tooling values such as stack, directories, and commands; it is tooling configuration, not product intent.
2. **Context firewall.** Captain to QM requires clean context. If the runtime clears context automatically, continue. If not, Captain tells the user to clear the session or start a fresh session before `/qm`; QM refuses if Captain or human discovery context is visible. No agent memory system, memory bank, persistent context store, or similar mechanism MAY be used to circumvent this firewall. Product intent MUST exist only in durable repository artifacts (`.feature` specs, `assets/**`, `watchbill.json`); any agent-internal memory that preserves discovery chat, rationale, abandoned ideas, or hidden instructions across the Captain to QM boundary is a violation.
3. **Fresh hand-off first.** On any role transition, the preceding role's final-report blockers and open questions are the first work item. A transition MAY involve several conditions; handle blockers first, then other duties. Current hand-off evidence takes priority over older notes.
4. **Write scopes are strict.** Captain writes specs, assets, `CAPTAIN.md`, and optional `watchbill.json`; QM writes verification, fixtures, step definitions, and test support; Crew writes production code only; Boatswain writes hygiene edits and commits, not new behaviour; Shipwright writes `@captain`-tagged scenario skeletons under the specs directory from `RIGGING.md` and `@planks(...)` trace annotations on production seams. Captain MAY add a perturbation when current durable context needs production attention and verification still passes. This is the only Captain exception to production-code custody. Captain uses the `fail-fast` value from `RIGGING.md`.
5. **Current design only.** Specs and code describe the current design. History lives in git. Remove superseded scenarios, tombstones, dated narration, orphaned steps, stale fixtures, unreachable code, and implementation that carries old requirements when safe; raise Captain blockers when ambiguous. A production seam with no `@planks(...)` link is either unspecified behaviour or dead code. In harbour, Shipwright planks unspecified behaviour by writing a `@captain` scenario. `@shipwright` marks condemned material on either surface: Captain retags a discarded `@captain` scenario to `@shipwright`, and Boatswain flags a spec-less dead seam with a `@shipwright` docblock. Shipwright removes condemned scenarios and code during harbour. Boatswain limits hygiene to the current watchbill scope, verification dry-run output, and uncommitted changes. Boatswain flags dead code but does not sweep the entire codebase or delete production code.
6. **Simplest sufficient change.** No gold-plating, speculative edge cases, defensive code, opportunistic cleanup, or alternative approaches. One role, one job, smallest useful change. Crew is work shy: the current failing target is the only requirement. Premature DRY (extracting helpers, creating interfaces, adding abstraction before the scenario demands it) and YAGNI violations (parameters, options, config, hooks, extension points for imagined futures) are forbidden.
7. **Real by default.** Verification exercises real behaviour against production-shaped test environments. No mocks, fakes, dummy credentials, `.invalid` endpoints, simulated CLIs, or stand-ins for the normal path.
8. **Exceptional doubles are narrow.** A double is allowed only for a specific condition the real environment genuinely cannot produce on demand. Mark and justify it inline (for example `@exceptional-double`). It MUST never replace normal-path real coverage.
9. **Harmless by design.** Tests that create or mutate real resources namespace every created object, never modify or delete resources they did not create, use safe or test-mode inputs where relevant, and register idempotent best-effort teardown. Namespaced test-created resources are disposable.
10. **Passing verification is not proof.** Passing checks only show that current checks pass. Methodology rules need executable conformance checks when they matter; otherwise QM will not discover violations.
11. **Three layers.** Specs and assets are durable artifacts. Production code is disposable from specs. Verification/harness is also disposable from specs and has its own conformance obligations.
12. **Directed work uses `watchbill.json`.** Captain SHOULD write fixed-shape `watchbill.json` when QM or Crew work should stay focused, save time, or save tokens. It selects and orders a subset of verification-discoverable scenario work. It contains only ordered watch objects (`watch1`, `watch2`, etc.); each watch contains only `scenarios`, an array of references in `<spec>.feature:<Scenario Name>` form. `watchbill.json` is scenario-level only. No prose, metadata, work-type enums, or hidden context. `watchbill.json` does not create work that verification cannot discover. Watch objects are ordering groups only. QM processes all watches in order unless verification, product intent, environment, or tooling blocks. If `watchbill.json` and verification disagree, verification wins. Captain MAY update or remove `watchbill.json`. A spent watchbill is struck: when its scenarios are verified, Captain removes the file. Absent at rest is the healthy state.
13. **Use they/them pronouns** for all roles and agents.
14. **Use Shipshape Controlled English.** Use IETF `en-CA-basiceng` where a language tag is useful; use Canadian spelling, controlled common vocabulary, precise technical terms, short sentences, explicit subjects, and a neutral professional register; use **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** as defined by RFC 2119 and RFC 8174; use a light nautical tone only in headings, greetings, and role names; avoid colloquial idiom, regional assumptions, marketing hyperbole, unclear metaphor, and vague claims; preserve technical identifiers, file paths, commands, schema keys, tags, and quoted literals unless the quoted text is prose being specified; use only characters from a US 101-key keyboard; no em dashes, smart quotes, or other non-ASCII punctuation; avoid parenthetical asides. If a sentence needs a dash, comma-pair, or parenthetical break, rewrite it as two sentences. State what is, not what is absent. Negation primes the negated concept, so describe the positive state and omit concepts that do not belong rather than asserting their absence. Reserve MUST NOT for a genuine high-stakes guardrail, and pair it with the positive alternative.
15. **Code exposes verification seams.** Production code SHOULD expose narrow, observable seams for scenario behaviour. Keep product logic separate from side effects where practical so verification can exercise real behaviour deliberately. Avoid hidden behaviour in global state, constructors, static initialization, singletons, registries, service locators, and framework lifecycle hooks. Testability refactors MUST serve current verification-discovered work, not speculative architecture cleanup. Verification seams MUST NOT replace normal-path real coverage with mocks, fakes, test-only branches, or harness-only behaviour.
16. **Deferral is not safety.** Stopping short does not reduce real risk. It only adds latency. Once intent is clear, push to 100% completion in the fewest possible cycles. Minimize cycles by batching all known work into the current pass. Minimize cycle time by preferring targeted verification over full tier runs; full tier runs are boundary checks, not the default inner loop. Do not pause to ask whether to continue when the next step is obvious. Captain batches all known work into the current pass. Shipwright completes the full harbour inventory. QM finishes the current watch. Crew finishes the assigned target or reports a real blocker. Boatswain finishes hygiene and verification recheck. Reserve a stop for an actual blocker, missing tool, contradictory spec, absent credential, and name it plainly.
17. **Every production seam is planked.** Planks are the behaviour-bearing production code required by Gherkin step contracts. Shipshape coins the term. Shipshape does not trace individual planks. It traces plank sets by annotating the smallest stable production seam that owns the behaviour with `@planks("<Gherkin step>")`. Not every step requires Planks, but every production seam MUST have at least one `@planks(...)` annotation. A seam MUST NOT contain behaviour outside its related step contracts. Extra behaviour is missing specification, misplaced code, or dead code.

## Core concepts

| Concept | Layer | Owned by | Purpose | Example |
|---|---|---|---|---|
| Step | Spec | Captain | Durable product contract | `When the customer pays with the saved card` |
| Seam | Production | Crew | Stable behaviour surface that carries Planks | `export async function payWithSavedCard()` |
| Plank | Trace | Crew, Shipwright | Links seam to step contract | `@planks("When the customer pays with the saved card")` |

A seam may carry Planks for several steps. A step may be carried by Planks on several seams.

## Scenario-writing agreement

Follow this scenario-writing agreement. Shipshape uses specification by example: each scenario is a concrete example that defines the behaviour contract. Captain and Shipwright MUST apply this agreement when writing binding or `@captain` scenarios. QM and Boatswain use it to evaluate scenario quality.

- Every feature file SHOULD describe one `Feature` unless project policy differs. Use stable vocabulary from the domain and product.
- Format Gherkin with 2-space indentation SHOULD, one blank line between scenarios SHOULD, and no blank lines between steps MUST.
- Every scenario describes one real, falsifiable behaviour needed by the current iteration. Keep titles single-line, behaviour-focused, and specific.
- Each scenario is independent; no scenario depends on another scenario running first.
- Write at the domain or product level. Specify UI, API, database, navigation, or harness plumbing only when that layer is the behaviour under test.
- `Given` is concrete starting state, `When` is one named action or input, and `Then` is an observable assertion. Use strict `Given`, `When`, `Then` order with no repeated phases.
- Use `And` and `But` sparingly for same-phase continuation.
- Use minimal sufficient `Given` state. Use `Background` only for shared starting state, not incidental setup.
- Assert outcomes, not mechanisms, unless the mechanism itself is the contract under test. Prefer state over navigation.
- Use concrete, realistic data: real flags, commands, keys, hostnames, files, asset paths, and example values. Use placeholder or nonsense values only when the scenario tests invalid input.
- Write steps as third-person present-tense subject-predicate statements. Use double quotes for string parameters.
- Put one action or assertion in each step. Split a compound step into separate steps.
- Write positive observable `Then` outcomes, not prohibitions: assert the state, output, permission, runtime field, file, or external observable that proves the rule.
- State a concrete observable signal as the outcome.
- Testability, not subject, decides what can be specified. Product behaviour, harness conformance, agent behaviour, and runtime enforcement can all be scenarios if falsifiable. Performance budgets, authorization invariants, accessibility requirements, and other cross-cutting concerns are expressible as scenarios and become discoverable when they fail.
- Keep one quality concern per scenario. Aim for fewer than about 10 steps.
- Use `Scenario Outline` only when the same behaviour is checked with input variations. Use tables for data instead of step spam, and doc strings for structured payloads.
- Keep tables concise with descriptive headers. If a table does not fit one screen, split the behaviour or move data to an asset.
- Avoid faux steps, abstract subjects, actor assertions, hedge words, and behaviour hidden in `Rule:` prose. `Rule:` prose MAY provide context only when it helps QM or Crew understand durable constraints that do not fit cleanly in steps; executable requirements belong in scenarios.
- Use `@property` for cross-cutting invariants, including agent-behaviour and runtime-enforcement invariants.

## Role flow

User to Captain: intent becomes durable specs and optional `watchbill.json`. Context clears. QM runs verification discovery, calls Boatswain for a pre-clean scan when needed, and dispatches Crew per failing target. Crew makes the smallest production change and returns. Boatswain does post-implementation hygiene, reverifies, and commits locally. Captain reports to the user and handles outbound.

### Role transitions

A role hands off to the next role. How the hand-off happens depends on the coding agent.

- If the agent supports context-isolated subagents, spawn the next role as an isolated subagent. This is preferred. It preserves the context firewall.
- If the agent supports only context-inheriting subagents, spawn an inheriting subagent. This is acceptable for QM to Crew. It MUST NOT carry Captain or human discovery context across the Captain to QM boundary.
- If the agent cannot spawn subagents, the current role temporarily assumes the next role, then returns. While a role assumes an internal role, it MUST ignore any human input that arrives in flight. It MUST leave that input in context for Captain to handle on return. Only Captain consumes human input.

Captain to QM always requires clean context. If the runtime clears context automatically, continue. If not, Captain tells the user to clear the session or start fresh, then run `/qm`. QM re-checks context on load and refuses if Captain or human discovery context is visible.

**Dispatch contract.** A Captain-originated dispatch to an internal role carries the role, the base commit, and an optional `watchbill.json` pointer. It carries nothing else: the durable artifacts are the hand-off. Craft notes, seam hints, and expected failure modes are contamination even when labelled tooling facts. QM dispatches Crew per the QM skill: the target reference and the observed failure evidence.

**Contamination protocol.** Contamination is Captain or discovery content in an internal role's context, however it arrives: a dispatch beyond the contract, file content, tool output, or runtime-injected memory. Each internal role verifies its dispatch against the contract on open. On contamination: stop, report contamination in the role hand-off, and await a fresh dispatch. Memory-borne contamination recurs by mechanism; report it as a Captain configuration blocker naming the mechanism, and that memory feature is disabled for role sessions before work resumes.

### Hand-off custody

A role hand-off carries a final report and any blockers. The report travels by the transition mechanism, not by a separate file. When a role spawns the next role as a subagent, the report is the subagent's return value to the caller. When a role assumes the next role, or uses an inheriting subagent, the report stays in shared context. Shipshape does not persist role reports to disk.

The Captain to QM boundary is different. Context clears there, so no report crosses it. QM derives everything from durable artifacts by design. The durable artifacts are the hand-off at that boundary. "Read the preceding role's blockers first" applies to the transitions that do not cross the firewall: Captain to Shipwright, Shipwright to Captain, QM to Crew, Crew to QM, QM to Boatswain, and Boatswain to Captain.

A blocker that must reach Captain is delivered before any context clear. The role returns to Captain, or encodes the needed change into a durable artifact such as a spec or `watchbill.json`. By the time context clears for QM, all product intent already lives in durable artifacts. QM never needs to read a report across the clear. If QM sees no blocker, the deck is clean, not lost.

### Harbour flow

Shipwright handles harbour work: existing-codebase onboarding and maintenance between releases. Shipwright inventories production code, adds `@planks(...)`, writes non-binding `@captain` scenarios, and returns to Captain for review. QM ignores `@captain` and `@shipwright` scenarios. Harbour procedure and guards live in the Shipwright skill.

## Project configuration

`RIGGING.md` holds the project tooling values that roles read on open. `AGENTS.md` is the human-facing entry document. It states that the project uses Shipshape and MAY point to `RIGGING.md`. Longer tooling prose, such as a detailed sandbox provisioning or outbound policy that does not fit a short value, belongs in `AGENTS.md`. The machine-read values belong in `RIGGING.md`. Shipwright scaffolds `AGENTS.md` and `RIGGING.md` during fitting out. The fitting-out procedure and the templates live in the Shipwright skill.

### Rigging

`RIGGING.md` uses a fixed Markdown shape. Roles read it on open and parse it by heading. It holds values, not procedure. Procedure lives in the skills. Use these sections:

- `## Stack`: `language`, `runtime`, and `packageManager`.
- `## Directories`: `implementation`, `specs`, `verification`, and `assets` paths. `implementation` MAY list several paths, including packaging config. Widen Crew scope only to work a falsifiable spec covers; work covered only by outbound policy stays Captain-owned.
- `## Commands`: `discover`, `focused`, `broad`, `coverage`, `step-usage`, `plank-inventory`, `typecheck`, and `lint`. Each value is a single command. The `focused` command uses `{scenario}` as the target placeholder. Watchbill-selected runs use the `focused` command for each scenario in the watch. The `plank-inventory` command lists docblock annotations in the implementation directory. A project MAY add tier-suffixed command variants, such as `coverage-sandbox`. All verification commands MUST exclude `@captain`-tagged and `@shipwright`-tagged scenarios.
- `## Perturbation`: the stable `message` and project-specific `fail-fast` statement.
- `## Tiers`: the `default` tier tag, any `sandbox` tier tag, and the credentials or sandbox provisioning policy for each tier.
- `## Dependencies`: the dependency `policy`.
- `## Outbound`: the release or distribution artifact verification command or policy, when the project ships an artifact.
- `## Known false-failure modes`: short notes a role rules out before routing a product defect.

A context-isolated Crew mate MUST be able to succeed from `RIGGING.md` alone. The minimum required values are `language` under `## Stack`, `implementation` under `## Directories`, `focused` under `## Commands`, and `fail-fast` under `## Perturbation`. Other sections are optional but SHOULD be present when the project needs them. Roles validate `RIGGING.md` on read. A malformed file or a missing required value is a configuration blocker to Captain. Keep narrative short. Long rationale belongs in `AGENTS.md`, not `RIGGING.md`.

## Project policies

These policies apply to all Shipshape project work.

### Blocker policy

If QM, Crew, Boatswain, or Shipwright encounters missing or contradictory product intent, they report a Captain blocker with concrete evidence in their role hand-off. Captain updates durable specs, and assets when the asset itself changes. After Captain resolves product intent, auto-clear or clear/start fresh before returning to QM.

### Asset policy

`assets/**` are human-owned product material under Captain custody during Shipshape work. The human operator owns product decisions and content. Captain MAY edit assets to capture approved product material, examples, fixtures, screenshots, pages, copy, media, or other support material.

Assets MAY be referenced by scenarios or verification. Assets MUST NOT define Shipshape workflow, hidden requirements, backlog, rationale, project memory, or agent instructions. Only `.feature` specs and verification output create agent work. Product-facing content SHOULD live in assets or project-approved content catalogs. If asset content or exact catalog content must be protected as behaviour, Captain specifies that behaviour in a `.feature` scenario. Guaranteed behaviour promotes to a `.feature` scenario; the asset body carries craft only.

### Artifact authority policy

Do not create extra binding Shipshape artifact types such as constitution, project-rules, memory-bank, decision-log, architecture-notes, roadmap, or backlog files. Product behaviour belongs in `.feature` files. Tooling configuration belongs in `AGENTS.md` and `RIGGING.md`. Directed work selection belongs in `watchbill.json`. Captain-only non-binding notes belong in `CAPTAIN.md`. Historical rationale belongs in git history and commit messages.

### Verification policy

Use project-specific commands from `RIGGING.md`. Progress is measured by verification status, not by a separate checklist. Prefer discovery, Watchbill-selected runs, and focused checks over full tier runs. Full tier runs are boundary checks, not the default inner loop. Passing checks are evidence, not proof. Skipped verification is unverified. Reports MUST distinguish fresh results from cache-backed results. QM owns verification procedure details.

Methodology rules can be self-enforcing. A `@property` scenario MAY scan verification support code for forbidden doubles, making the real-by-default rule executable and its violations discoverable.

### Perturbation policy

A perturbation marks a behaviour-stable seam for reimplementation. Scenarios pin behaviour. Durable context also carries requirements that leave behaviour unchanged: a `Rule:` in a feature, a coding standard in `AGENTS.md`, a dependency or tooling value in `RIGGING.md`. When such a requirement changes, a seam can pass every step and still fall out of compliance. Captain adds the `fail-fast` statement from `RIGGING.md` at the seam, and the seam becomes a failing verification target. QM discovers the failure and dispatches it like any other failing target. Crew reimplements the seam from current durable context and removes the perturbation statement with the reimplemented seam. The scenarios passing again prove the behaviour survived the rebuild. Boatswain verifies each removed perturbation against current durable context before commit.

A perturbation MUST become a failing verification target. A perturbation that stays green has discovered an unexercised seam or a stale-green scenario. QM blocks to Captain with that evidence, and Boatswain treats a live perturbation in a green tree as a foul deck.

### Verification-shaped code policy

Production code SHOULD expose narrow, observable seams for real scenario behaviour. Verification seams MUST support real behaviour, not mocks, fakes, test-only branches, simulated CLIs, `.invalid` endpoints, dummy credentials, or harness-only behaviour. Crew MAY refactor production code to expose a verification seam only when that is the smallest sufficient change for the assigned failing target. Role-specific seam guidance lives in QM, Crew, Boatswain, and Shipwright.

### Outbound verification policy

Captain handles outbound decisions (push, PR, publish, release, deploy). Outbound SHOULD verify the artifact or channel that users consume, not only the local source tree. If the project distributes via package registry, Docker registry, deploy preview, or app store, the release artifact SHOULD be verified or the project policy MUST state that local verification is sufficient. Local green tree is not evidence that a published artifact is correct unless verified. A project MAY ship several distribution targets, such as a package and a separately deployed site. Name every target in `RIGGING.md` under `## Outbound` and verify each; targets deploy independently unless the policy states otherwise.

### Traceability policy

Feature files are canon. Shipshape derives trace from current feature files, through scenarios and steps, into step definitions and production seams. Trace annotations MUST NOT define product intent, create worklists, or replace verification discovery. Worklists come from undefined, unimplemented, or failing verification, optionally selected and ordered by `watchbill.json`.

An individual plank may be as small as an argument, expression, branch, call, state change, or persisted value. Trace annotations are hoisted to seams because Planks may be distributed below that boundary.

Use the project comment form for trace annotations. `@planks("<Gherkin step>")` marks a production seam whose behaviour is required by that exact step. Include the Gherkin keyword. Normalize `And` and `But` to the inherited `Given`, `When`, or `Then`.

Not every step requires Planks. Setup and assertion steps often use only verification support. Every production seam MUST have at least one `@planks(...)` annotation.

A seam MAY carry Planks for several steps. A step MAY be carried by several seams. A seam MUST NOT contain behaviour outside its related step contracts. Extra behaviour is missing specification, misplaced code, or dead code.

Do not trace production code to features or scenarios. Scenario coverage is derived through Cucumber's scenario-to-step mapping. Support artifacts MAY use project-appropriate comments when ownership or deletion is unclear, but they MUST NOT define product intent.

### Coverage report convention

Generated coverage reports are transient verification output. They MUST NOT define product intent, create work, or become durable planning artifacts.

### Tier tags

| Tag | Purpose | Default |
|---|---|---|
| `@logic` | Pure local tests, no external accounts. Fast, deterministic, safe. | Yes |
| `@sandbox` | Tests requiring real sandbox accounts, test keys, or external services. | No |

Projects MAY define additional opt-in tiers. Each tier has its own tag and policy in `RIGGING.md`.

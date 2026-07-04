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

Shipshape uses the pirate-ship model. Quartermaster is the crew-empowered role that allocates work and can overrule the Captain on matters of the working order. Boatswain keeps the deck clean. Crew does the work. Captain faces the world.

An enforcing runtime is a harness that mechanizes these rules, such as the Shipshape plugin. A skill-only agent has only this text and follows the rules by discipline. Skill-only agents enter a role when the user types the role command such as `/captain`. Enforcing runtimes MAY select the role automatically.

Only Captain talks to the user. QM, Crew, Boatswain, and Shipwright are internal roles; they report through durable artifacts, verification output, and role hand-offs.

## Entry

When loaded bare via `/shipshape`, this skill routes to the correct role. The routing depends on the project state.

1. Look for `RIGGING.md` at the project root. If absent, the project is not fitted out. Route to `/shipwright` for fitting out and harbour inventory.
2. If `RIGGING.md` is present, the project is fitted out. Route to `/captain` for normal spec-driven work.
3. Load the chosen role's `SKILL.md`. The role skill inherits these shared Articles and policies.

A coding agent that loads this skill by a direct role command such as `/captain` skips this routing and enters the role directly.

## Voice

### Shipshape Controlled English

Use IETF `en-CA-basiceng` where a language tag is useful; use Canadian spelling, controlled common vocabulary, precise technical terms, short sentences, explicit subjects, and a neutral professional register; use **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** as defined by RFC 2119 and RFC 8174; use defined nautical terms of art as controlled vocabulary throughout, and keep the surrounding register plain and professional; avoid colloquial idiom, regional assumptions, marketing hyperbole, unclear metaphor, and vague claims; preserve technical identifiers, file paths, commands, schema keys, tags, and quoted literals unless the quoted text is prose being specified; use only characters from a US 101-key keyboard; no em dashes, smart quotes, or other non-ASCII punctuation; avoid parenthetical asides. A parenthetical aside carries an inference and comprehension cost, so if a sentence needs a dash, comma-pair, or parenthetical break, rewrite it as two sentences. State what is, not what is absent. Negation primes the negated concept, so describe the positive state and omit concepts that do not belong rather than asserting their absence. Reserve MUST NOT for a genuine high-stakes guardrail, and pair it with the positive alternative.

### Internal-role voice

Internal roles QM, Crew, Boatswain, and Shipwright use smart-but-silent voice:

- Drop articles (`a`, `an`, `the`) and filler (`just`, `really`, `basically`, `actually`).
- Drop pleasantries (`sure`, `certainly`, `happy to`).
- No hedging. Fragments fine. Short synonyms.
- Technical terms remain exact. Code blocks remain unchanged.
- No customer-facing prose.
- State the role name at the head of every report.
- Pattern: `[thing] [action] [reason]. [next step].`

## Core concepts

Shipshape has three layers. Specs and assets are durable artifacts. Production code is disposable from specs. Verification and harness are also disposable from specs and carry their own conformance obligations.

| Concept | Layer | Owned by | Purpose | Example |
|---|---|---|---|---|
| Step | Spec | Captain | Durable product contract | `When the customer pays with the saved card` |
| Seam | Production | Crew | Stable behaviour surface that carries Planks | `export async function payWithSavedCard()` |
| Plank | Trace | Crew, Shipwright | Links seam to step contract | `@planks("When the customer pays with the saved card")` |

A seam may carry Planks for several steps. A step may be carried by Planks on several seams.

## Articles of Agreement

These are shared Shipshape declarations. Enforcing runtimes MAY implement them as hard constraints; skill-only agents follow them by explicit discipline. The mechanics live in the named sections and policies below. Cite an Article by its title. The five groups answer five questions in reading order.

### What is true

1. **Durable artifacts outrank chat.** Binding product behaviour lives in valid `.feature` files. `assets/**` are human-owned product material under Captain custody; the Asset policy carries the rules. Conversation context is discarded. `CAPTAIN.md`, if present, contains Captain-only non-binding notes. `AGENTS.md` and `RIGGING.md` are tooling configuration, not product intent; the Project configuration section carries their shapes.
2. **Current design only.** Specs and code describe the current design. History lives in git. Remove superseded scenarios, tombstones, dated narration, orphaned steps, stale fixtures, unreachable code, and implementation that carries old requirements when safe; raise Captain blockers when ambiguous. A production seam with no `@planks(...)` link is either unspecified behaviour or dead code. Unspecified behaviour gets a `@captain` scenario in harbour. Dead code does not block the voyage: it is marked and deferred to harbour. `@shipwright` condemns a scenario; the tagging and removal rules live in the role skills.
3. **Every production seam is planked.** Planks are the behaviour-bearing production code required by Gherkin step contracts. Every production seam MUST have at least one `@planks(...)` annotation, and MUST NOT contain behaviour outside its related step contracts. The Traceability policy carries the annotation mechanics.
4. **Directed work uses `watchbill.json`.** Captain SHOULD write fixed-shape `watchbill.json` when QM or Crew work should stay focused. It selects and orders a subset of verification-discovered work and creates none. If `watchbill.json` and verification disagree, verification wins. A spent watchbill is struck: when its scenarios are verified, Captain removes the file. Absent at rest is the healthy state. The Watchbill policy carries the file shape.

### Who may act

5. **Context bulkhead.** Captain to QM requires clean context. No agent memory system, memory bank, persistent context store, or similar mechanism MAY be used to circumvent this bulkhead. Product intent MUST exist only in durable repository artifacts: `.feature` specs, `assets/**`, and `watchbill.json`. Any agent-internal memory that preserves discovery chat, rationale, abandoned ideas, or hidden instructions across the Captain to QM boundary is a violation. The clean-context mechanics, dispatch contract, and contamination protocol in Role transitions carry the bulkhead mechanics.
6. **Fresh hand-off first.** On any role transition, the preceding role's final-report blockers and open questions are the first work item. A transition MAY involve several conditions; handle blockers first, then other duties. Current hand-off evidence takes priority over older notes.
7. **Write scopes are strict.** Captain writes specs, assets, `CAPTAIN.md`, and optional `watchbill.json`; QM writes verification, fixtures, step definitions, and test support; Crew writes production code only; Boatswain writes hygiene edits and commits, not new behaviour; Shipwright writes `@captain`-tagged scenario skeletons under the specs directory from `RIGGING.md` and `@planks(...)` trace annotations on production seams. Write-scope exceptions: Boatswain MAY mark a scenario `@shipwright` to condemn it; Captain MAY add a perturbation to production code, per the Perturbation policy; Captain MAY write a tooling value into `RIGGING.md` when resolving a rigging or dependency blocker with the user.

### How work proceeds

8. **Simplest sufficient change.** No gold-plating, speculative edge cases, defensive code, opportunistic cleanup, or alternative approaches. One role, one job, smallest useful change. Crew is work shy: the current failing target is the only requirement. Premature DRY is forbidden, such as extracting helpers, creating interfaces, or adding abstraction before the scenario demands it. YAGNI violations are forbidden, such as parameters, options, config, hooks, or extension points for imagined futures.
9. **Deferral is not safety.** Stopping short does not reduce real risk. It only adds latency. Once intent is clear, push to 100% completion in the fewest possible cycles: batch all known work into the current pass, and prefer targeted verification over full tier runs. Do not pause to ask whether to continue when the next step is obvious. Reserve a stop for an actual blocker, missing tool, contradictory spec, or observed authentication failure, and name it plainly.

### How it is proven

10. **Real by default.** Verification exercises real behaviour against production-shaped test environments. No mocks, fakes, dummy credentials, `.invalid` endpoints, simulated CLIs, or stand-ins for the normal path.
11. **Exceptional doubles are narrow.** A double is allowed only for a specific condition the real environment genuinely cannot produce on demand. Mark and justify it inline, for example with `@exceptional-double`. It MUST never replace normal-path real coverage.
12. **Harmless by design.** Tests that create or mutate real resources namespace every created object, never modify or delete resources they did not create, use safe or test-mode inputs where relevant, and register idempotent best-effort teardown. Namespaced test-created resources are disposable.
13. **Code exposes verification seams.** Production code SHOULD expose narrow, observable seams for scenario behaviour. Keep product logic separate from side effects where practical so verification can exercise real behaviour deliberately. Avoid hidden behaviour in global state, constructors, static initialization, singletons, registries, service locators, and framework lifecycle hooks. Testability refactors MUST serve current verification-discovered work, not speculative architecture cleanup. Verification seams MUST NOT replace normal-path real coverage with the doubles the "Real by default" Article forbids.
14. **Passing verification is not proof.** Passing checks only show that current checks pass. Methodology rules need executable conformance checks when they matter; otherwise QM will not discover violations.

### How it is written

15. **Use Shipshape Controlled English.** All Shipshape writing uses Shipshape Controlled English. The Voice section carries the mechanics: vocabulary, register, RFC 2119 terms, ASCII punctuation, and positive statement.
16. **Use they/them pronouns** for all roles and agents.

## Scenario-writing agreement

Shipshape uses specification by example: each scenario is a concrete example that defines a behaviour contract. Describe behaviour, not implementation. The scenario is durable and the code beneath it is disposable, so a scenario must survive a rebuild of that code; if a step would change when only the implementation changes, raise it to the behaviour level. Write for humans first: any reader should understand what happens and what proves it. Captain and Shipwright apply this when writing binding or `@captain` scenarios; QM and Boatswain use it to judge scenario quality.

Feature file:

- One `Feature` per file unless project policy differs. Use stable domain vocabulary.
- Indent with 2 spaces. Scenarios SHOULD be separated by one blank line. A scenario's steps MUST be contiguous.

Each scenario:

- Covers one real, falsifiable behaviour needed now, holds one quality concern, and stays within about 10 steps. Give it a single-line, specific, behaviour-focused title.
- Is independent: it never depends on another scenario running first.
- Sits at the domain or product level. Specify UI, API, database, or harness plumbing only when that layer is the behaviour under test.

Steps:

- `Given` is concrete starting state, `When` is one named action, `Then` is one observable assertion. Keep strict `Given`, `When`, `Then` order with no repeated phase; use `And` and `But` sparingly for same-phase continuation. Gherkin has no `Or`; split a choice into separate scenarios or a `Scenario Outline`.
- Use minimal sufficient `Given` state, and prefer state over navigation: assert the user is signed in rather than scripting the click path to sign in. Use `Background` only for shared starting state.
- Write third-person present-tense subject-predicate statements, one action or assertion each, with double quotes for string parameters. Split compound steps.

Outcomes:

- Write a positive, observable `Then`: assert the state, output, file, permission, runtime field, or external signal that proves the rule. Assert outcomes, not mechanisms, unless the mechanism is the contract under test.

Data:

- Use concrete, realistic data: real flags, commands, keys, hostnames, files, and asset paths. Use placeholder or nonsense values only when testing invalid input.
- Use `Scenario Outline` only when one behaviour runs with input variations. Put data in tables and structured payloads in doc strings; keep tables concise with descriptive headers, and split any table that overflows the screen or move it to an asset.

What can be a scenario:

- Testability, not subject, decides. Product behaviour, harness conformance, agent behaviour, runtime enforcement, performance budgets, authorization, and accessibility can all be scenarios when falsifiable, and become discoverable when they fail.
- Tag a cross-cutting invariant `@property`.
- Content behaviour can be a scenario, but only the seam you own. When a third-party generator renders the content, that seam is invoking and configuring it correctly; assert that it runs and produces the expected output. The asset carries the copy and the generator owns its rendering.
- A standard contract is a machine-readable, testable specification of mechanical shape, such as an OpenAPI document, a JSON Schema, or a GraphQL schema. Conformance to a standard contract can be a scenario: reference the contract asset and assert the seam conforms. The Gherkin holds the user or business behaviour; the contract asset holds the mechanical shape such as fields, status codes, and structure. Do not duplicate contract shapes in prose.

Avoid:

- Steps that assert nothing observable, steps whose subject is an abstraction rather than a named actor or system, steps asserting an actor's intent rather than a result, and steps hedged with words such as `should probably` or `might`. Avoid executable requirements buried in `Rule:` prose; `Rule:` prose adds durable context only, and requirements belong in scenarios.
- Automation and UI mechanics in step text: selectors, XPath, element IDs, and waits belong in step definitions, not scenarios.

## Role flow

User to Captain: intent becomes durable specs and optional `watchbill.json`. Context clears. QM runs verification discovery, calls Boatswain for a pre-clean scan when needed, and dispatches Crew per failing target. Crew makes the smallest production change and returns. Boatswain does post-implementation hygiene, reverifies, and commits locally. Captain reports to the user and handles outbound.

### Role transitions

A role hands off to the next role. How the hand-off happens depends on the coding agent.

- If the agent supports context-isolated subagents, spawn the next role as an isolated subagent. This is preferred. A fresh context window carries no Captain content, which satisfies the clean-context bulkhead and prevents accidental contamination.
- A fresh context window is the isolation floor. Where the runtime shares an on-disk transcript across that boundary, the transcript is a residual side channel. It is discarded conversation context, never product intent, and an internal role MUST NOT mine it. The runtime SHOULD block internal-role reads of the transcript; a fresh session carries a fresh transcript and closes the residual fully. Do not force a fresh session on a routine transition where a window-isolated subagent already carries no Captain content; reserve that cost for opt-in strict work.
- If the agent supports only context-inheriting subagents, spawn an inheriting subagent. This is acceptable for QM to Crew. It MUST NOT carry Captain or human discovery context across the Captain to QM bulkhead.
- If the agent cannot spawn subagents, the current role temporarily assumes the next role, then returns. While a role assumes an internal role, it MUST ignore any human input that arrives in flight. It MUST leave that input in context for Captain to handle on return. Only Captain consumes human input.

Captain to QM always requires clean context. A window-isolated subagent or a fresh session both satisfy it. If the runtime provides isolation automatically, continue. If not, Captain tells the user to start a fresh session, then run `/qm`. A same-session clear resets the window but not the transcript, so it is the weaker option where the transcript persists. QM re-checks context on load and refuses if Captain or human discovery context is visible in its window.

**Dispatch contract.** A Captain-originated dispatch to an internal role carries the role, the base commit, and an optional `watchbill.json` pointer. It carries nothing else: the durable artifacts are the hand-off. Craft notes, seam hints, and expected failure modes are contamination even when labelled tooling facts. QM dispatches Crew per the QM skill: the target reference and the observed failure evidence.

**Contamination protocol.** Contamination is Captain or discovery content in an internal role's context, however it arrives: a dispatch beyond the contract, file content, tool output, or runtime-injected memory. Each internal role verifies its dispatch against the contract on open. On contamination: stop, report contamination in the role hand-off, and await a fresh dispatch. Memory-borne contamination recurs by mechanism; report it as a Captain configuration blocker naming the mechanism, and Captain disables that memory feature for role sessions before work resumes. The Boatswain note-hygiene read of `CAPTAIN.md` is exempt: `CAPTAIN.md` holds non-binding notes, not discovery transcript.

### Hand-off custody

A role hand-off carries a final report and any blockers. The report travels by the transition mechanism, not by a separate file. When a role spawns the next role as a subagent, the report is the subagent's return value to the caller. When a role assumes the next role, or uses an inheriting subagent, the report stays in shared context. Shipshape does not persist role reports to disk.

The Captain to QM boundary is different. Context clears there, so no report crosses it. QM derives everything from durable artifacts by design. The durable artifacts are the hand-off at that boundary. The bulkhead is one-directional, Captain to QM only. Blocker returns to Captain are ordinary hand-offs. "Read the preceding role's blockers first" applies to the transitions that do not cross the bulkhead: Captain to Shipwright, Shipwright to Captain, QM to Crew, Crew to QM, QM to Boatswain, Boatswain to QM, QM to Captain, and Boatswain to Captain.

A blocker that must reach Captain is delivered before any context clear: the role returns to Captain, or encodes the change into a durable artifact. If QM sees no blocker, the deck is clean, not lost.

### Harbour flow

Shipwright handles harbour work: existing-codebase onboarding and maintenance between releases. Shipwright inventories production code, adds `@planks(...)`, writes non-binding `@captain` scenarios, and returns to Captain for review. QM ignores `@captain` and `@shipwright` scenarios. Harbour begins only when the voyage is quiescent: the working tree is clean and no outbound is pending. Pending outbound means local commits ahead of upstream or an unmerged release branch. Harbour procedure and guards live in the Shipwright skill.

## Project configuration

`RIGGING.md` holds the project tooling values that roles read on open. `AGENTS.md` is the human-facing entry document. It states that the project uses Shipshape and MAY point to `RIGGING.md`. Longer tooling prose, such as a detailed sandbox provisioning or outbound policy that does not fit a short value, belongs in `AGENTS.md`. The machine-read values belong in `RIGGING.md`. Shipwright scaffolds `AGENTS.md` and `RIGGING.md` during fitting out. The fitting-out procedure and the templates live in the Shipwright skill.

### Rigging

`RIGGING.md` uses a fixed Markdown shape. Roles read it on open and parse it by heading. It holds values, not procedure. Procedure lives in the skills. Use these sections:

- `## Stack`: `language`, `runtime`, and `packageManager`.
- `## Directories`: `implementation`, `specs`, `verification`, and `assets` paths. `implementation` MAY list several paths, including packaging config. Widen Crew scope only to work a falsifiable spec covers; work covered only by outbound policy stays Captain-owned. `assets` MAY list several existing directories: fitting out declares content directories as assets in place and moves nothing.
- `## Commands`: `discover`, `focused`, `broad`, `coverage`, `step-usage`, `plank-inventory`, `typecheck`, and `lint`. Each value is a single command. The `focused` command uses `{scenario}` as the target placeholder. Watchbill-selected runs use the `focused` command for each scenario in the watch. The `plank-inventory` command lists docblock annotations in the implementation directory. A project MAY add tier-suffixed command variants, such as `coverage-sandbox`. A project that references a standard contract asset MAY add a `conformance` command that validates seams against that asset, so a conformance step runs a real check. All verification commands MUST exclude `@captain`-tagged and `@shipwright`-tagged scenarios.
- `## Perturbation`: the stable `message` and project-specific `fail-fast` statement. The `message` MUST contain the literal token `PERTURBATION` so a role can detect a live perturbation in the tree.
- `## Tiers`: the `default` tier tag, any `sandbox` tier tag, and the credentials or sandbox provisioning policy for each tier.
- `## Dependencies`: the dependency `policy`.
- `## Outbound`: the release or distribution artifact verification command or policy, when the project ships an artifact.
- `## Known false-failure modes`: short notes a role rules out before routing a product defect.

A context-isolated Crew mate MUST be able to succeed from `RIGGING.md` alone. The minimum required values are `language` under `## Stack`, `implementation` and `specs` under `## Directories`, `focused` under `## Commands`, and `fail-fast` under `## Perturbation`. Other sections are optional but SHOULD be present when the project needs them. Roles validate `RIGGING.md` on read. A malformed file or a missing required value is a configuration blocker to Captain. `RIGGING.md` is Shipwright's to derive and repair; Captain routes a rigging configuration blocker to Shipwright, which refits the missing values. Captain discovers a value with the user only when Shipwright cannot derive it. Keep narrative short. Long rationale belongs in `AGENTS.md`, not `RIGGING.md`.

## Project policies

These policies apply to all Shipshape project work.

### Blocker policy

If QM, Crew, Boatswain, or Shipwright encounters missing or contradictory product intent, they report a Captain blocker with concrete evidence in their role hand-off. Captain updates durable specs, and assets when the asset itself changes. After Captain resolves product intent, auto-clear or clear/start fresh before returning to QM. An environment or tooling blocker, such as a missing tool or an observed authentication failure, is also reported to Captain; a rigging or configuration blocker routes to Shipwright per the Rigging section.

A methodology check failure routes by artifact ownership: verification support to QM, trace annotations and plank drift to harbour, specs and `watchbill.json` to Captain. Crew is dispatched only for production-code failures.

### Working tree

Humans edit at any time. A role owns only the edits it makes and leaves every other working-tree change untouched. A role never treats the tree's existing state as its own work. Boatswain stages only role-advanced hunks and leaves unrelated operator work for Captain.

### Captain context

Captain context is disposable. Product intent lives in durable artifacts; Captain rebuilds working context from them plus `CAPTAIN.md`. A long-lived Captain SHOULD reset to a fresh context at durable voyage boundaries, after outbound and at a harbour mode change, so the session stays bounded and well grounded. An unbounded Captain session degrades grounding on modest models and wastes tokens on capable ones. The persona MAY be continuous; the working context is not. At a reset boundary Captain requests a fresh context. The operator MAY decline by explicit refusal, and Captain then continues; inaction is not refusal. Before any reset, Captain writes pending intent to durable artifacts so the fresh context loses nothing.

### Asset policy

`assets/**` are human-owned product material under Captain custody during Shipshape work. The human operator owns product decisions and content. Captain MAY edit assets to capture approved product material, examples, fixtures, screenshots, pages, copy, media, or other support material.

Assets MAY be referenced by scenarios or verification. Assets MUST NOT define Shipshape workflow, hidden requirements, backlog, rationale, project memory, or agent instructions. Only `.feature` specs and verification output create agent work. Product-facing content SHOULD live in assets or project-approved content catalogs. Content consumed by a build or generator, such as static-site pages, templates rendered as content, and data files, is product material under this policy, not production code. If asset content or exact catalog content must be protected as behaviour, Captain specifies that behaviour in a `.feature` scenario. Guaranteed behaviour promotes to a `.feature` scenario; the asset body carries craft only.

### Artifact authority policy

Do not create extra binding Shipshape artifact types such as constitution, project-rules, memory-bank, decision-log, architecture-notes, roadmap, or backlog files. Product behaviour belongs in `.feature` files. Tooling configuration belongs in `AGENTS.md` and `RIGGING.md`. Directed work selection belongs in `watchbill.json`. Captain-only non-binding notes belong in `CAPTAIN.md`. Historical rationale belongs in git history and commit messages.

### Watchbill policy

`watchbill.json` contains only ordered watch objects named `watch1`, `watch2`, and onward. Each watch contains only `scenarios`, an array of references in `<spec>.feature:<Scenario Name>` form, with no prose, metadata, or hidden context. Each reference is repo-root-relative and includes the specs directory. QM processes all watches in order unless verification, product intent, environment, or tooling blocks.

### Verification policy

Use project-specific commands from `RIGGING.md`. Progress is measured by verification status, not by a separate checklist. Prefer discovery, Watchbill-selected runs, and focused checks over full tier runs. Full tier runs are boundary checks, not the default inner loop. Passing checks are evidence, not proof. Skipped verification is unverified. Fitting out provisions credentials for every configured tier, so every configured tier is runnable by construction. Run each configured tier whenever the work calls for it. A tier run that fails to authenticate is evidence that fitting out is incomplete: report a Captain blocker with the failure output. Reports MUST distinguish fresh results from cache-backed results. QM owns verification procedure details.

Methodology rules can be self-enforcing. A `@property` scenario MAY scan verification support code for forbidden doubles, making the real-by-default rule executable and its violations discoverable. A derived methodology check is proven by a negative test: plant a violation, confirm the check reddens, remove the violation. A check that has never been red is unproven.

### Perturbation policy

A perturbation marks a behaviour-stable seam for reimplementation. Scenarios pin behaviour. Durable context also carries requirements that leave behaviour unchanged: a `Rule:` in a feature, a coding standard in `AGENTS.md`, a dependency or tooling value in `RIGGING.md`. When such a requirement changes, a seam can pass every step and still fall out of compliance. Captain adds the `fail-fast` statement from `RIGGING.md` at the seam, and the seam becomes a failing verification target. QM discovers the failure and dispatches it like any other failing target. Crew reimplements the seam from current durable context and removes the perturbation statement with the reimplemented seam. The scenarios passing again prove the behaviour survived the rebuild. Boatswain verifies each removed perturbation against current durable context before commit.

A perturbation MUST become a failing verification target. A perturbation that stays green has discovered an unexercised seam or a stale-green scenario. QM blocks to Captain with that evidence, and Boatswain treats a live perturbation in a green tree as a foul deck.

### Verification-shaped code policy

The "Code exposes verification seams" Article carries the seam obligations. Crew MAY refactor production code to expose a verification seam only when that is the smallest sufficient change for the assigned failing target. Role-specific seam guidance lives in QM, Crew, Boatswain, and Shipwright.

### Outbound verification policy

Captain handles outbound decisions such as push, PR, publish, release, and deploy. Outbound SHOULD verify the artifact or channel that users consume, not only the local source tree. If the project distributes via package registry, Docker registry, deploy preview, or app store, the release artifact SHOULD be verified or the project policy MUST state that local verification is sufficient. Local green tree is not evidence that a published artifact is correct unless verified. A project MAY ship several distribution targets, such as a package and a separately deployed site. Name every target in `RIGGING.md` under `## Outbound` and verify each; targets deploy independently unless the policy states otherwise.

### Traceability policy

Feature files are canon. Shipshape derives trace from current feature files, through scenarios and steps, into step definitions and production seams. Trace annotations MUST NOT define product intent, create worklists, or replace verification discovery. Worklists come from undefined, unimplemented, or failing verification, optionally selected and ordered by `watchbill.json`.

An individual plank may be as small as an argument, expression, branch, call, state change, or persisted value. Trace annotations are hoisted to seams because Planks may be distributed below that boundary.

Use the project comment form for trace annotations. `@planks("<Gherkin step>")` marks a production seam whose behaviour is required by that exact step. Include the Gherkin keyword. Normalize `And` and `But` to the inherited `Given`, `When`, or `Then`.

Not every step requires Planks. Setup and assertion steps often use only verification support.

A seam MAY carry Planks for several steps. A step MAY be carried by several seams. The "Every production seam is planked" Article carries the seam obligations: at least one `@planks(...)` annotation, and behaviour only within the related step contracts.

Do not trace production code to features or scenarios. Scenario coverage is derived through Cucumber's scenario-to-step mapping. Support artifacts MAY use project-appropriate comments when ownership or deletion is unclear, but they MUST NOT define product intent.

### Coverage report convention

Generated coverage reports are transient verification output. They MUST NOT define product intent, create work, or become durable planning artifacts.

### Tier tags

| Tag | Purpose | Default |
|---|---|---|
| `@logic` | Pure local tests, no external accounts. Fast, deterministic, safe. | Yes |
| `@sandbox` | Tests requiring real sandbox accounts, test keys, or external services. | No |

Projects MAY define additional opt-in tiers. Each tier has its own tag and policy in `RIGGING.md`.

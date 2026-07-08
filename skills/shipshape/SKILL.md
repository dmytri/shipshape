---
name: shipshape
description: "Use this skill to understand the Shipshape workflow, shared Articles of Agreement, and select the correct role skill: /captain, /qm, /crew, /boatswain, or /shipwright. Entry point when no role is active or the right role is unclear."
---

# Shipshape

Shipshape is a context-isolated, spec-driven workflow for coding agents.

**Specifications are durable. Code is disposable. Agents are replaceable.**

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

Use they/them pronouns for all roles and agents.

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

These are shared Shipshape declarations. Cite an Article by its title. Two groups by trigger. Dispositions are held at every moment; their trigger is internal, so they must shape every judgment. Custody Articles bind at a legible moment of action: a dispatch, a file write, a seam change. The Custody group is exactly the set an enforcing runtime enforces as hard constraints; a skill-only agent follows all nine by explicit discipline. Craft that applies at a named moment lives in the agreements, the policies, and the role skills; each Article points to its mechanics.

### Dispositions

1. **Durable artifacts outrank chat.** Binding product behaviour lives in valid `.feature` files. `assets/**` are human-owned product material under Captain custody; the Asset policy carries the rules. Conversation context is discarded; when chat and a durable artifact disagree, the artifact wins. `CAPTAIN.md`, if present, contains Captain-only non-binding notes. `AGENTS.md` and `RIGGING.md` are tooling configuration, not product intent; the Project configuration section carries their shapes.
2. **Current design only.** Specs and code describe the current design. History lives in git. Remove superseded scenarios, tombstones, dated narration, orphaned steps, stale fixtures, unreachable code, and implementation that carries old requirements when safe; raise Captain blockers when ambiguous. A production seam with no `@planks(...)` link is either unspecified behaviour or dead code. Unspecified behaviour gets a `@captain` scenario in harbour. Dead code does not block the voyage: it is marked and deferred to harbour. `@shipwright` condemns a scenario; the tagging and removal rules live in the role skills.
3. **Simplest sufficient change.** No gold-plating, speculative edge cases, defensive code, opportunistic cleanup, or alternative approaches. One role, one job, smallest useful change. Crew is work shy: the current failing target is the only requirement. Premature DRY is forbidden, such as extracting helpers, creating interfaces, or adding abstraction before the scenario demands it. YAGNI violations are forbidden, such as parameters, options, config, hooks, or extension points for imagined futures.
4. **Deferral is not safety.** Stopping short does not reduce real risk. It only adds latency. Once intent is clear, push to 100% completion in the fewest possible cycles: batch all known work into the current pass, and prefer targeted verification over full tier runs. Do not pause to ask whether to continue when the next step is obvious. Reserve a stop for an actual blocker, missing tool, contradictory spec, or observed authentication failure, and name it plainly.
5. **Real by default.** Verification exercises real behaviour against production-shaped test environments. No mocks, fakes, dummy credentials, `.invalid` endpoints, simulated CLIs, or stand-ins for the normal path. The Verification agreement carries the craft and the one narrow exception.
6. **Passing verification is not proof.** Passing checks only show that current checks pass. Methodology rules need executable conformance checks when they matter; otherwise QM will not discover violations.

### Custody

7. **Context bulkhead.** Captain to QM requires clean context. No agent memory system, memory bank, persistent context store, or similar mechanism MAY be used to circumvent this bulkhead. Product intent MUST exist only in durable repository artifacts: `.feature` specs, `assets/**`, and `watchbill.json`. Any agent-internal memory that preserves discovery chat, rationale, abandoned ideas, or hidden instructions across the Captain to QM boundary is a violation. The clean-context mechanics, dispatch contract, and contamination protocol in Role transitions carry the bulkhead mechanics.
8. **Write scopes are strict.** Captain writes specs, assets, `CAPTAIN.md`, and optional `watchbill.json`; QM writes verification, fixtures, step definitions, and test support; Crew writes production code only; Boatswain writes hygiene edits and commits, not new behaviour; Shipwright writes `@captain`-tagged scenario skeletons under the specs directory from `RIGGING.md` and `@planks(...)` trace annotations on production seams. Write-scope exceptions: Boatswain MAY mark a scenario `@shipwright` to condemn it; Captain MAY add a perturbation to production code, per the Perturbation policy; Captain MAY write a tooling value into `RIGGING.md` when resolving a rigging or dependency blocker with the user.
9. **Every production seam is planked.** Planks are the behaviour-bearing production code required by Gherkin step contracts. Every production seam MUST have at least one `@planks(...)` annotation, and MUST NOT contain behaviour outside its related step contracts. The Traceability policy carries the annotation mechanics; the "Current design only" Article carries the judgment on unplanked seams.

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
- A scantling can be referenced by a scenario per the Scantling agreement; the scenario asserts conformance or, for a proof, attests a clean discharge.

Avoid:

- Steps that assert nothing observable, steps whose subject is an abstraction rather than a named actor or system, steps asserting an actor's intent rather than a result, and steps hedged with words such as `should probably` or `might`. Avoid executable requirements buried in `Rule:` prose; `Rule:` prose adds durable context only, and requirements belong in scenarios.
- Bare `#` comments in `.feature` files. Durable non-requirement context belongs in `Rule:` prose; anything non-durable, chat, rationale, or hidden instructions, belongs in `CAPTAIN.md`, which QM, Crew, and Shipwright never read. A comment is neither and reaches every role that reads the spec, so it crosses the Context bulkhead by construction.
- Automation and UI mechanics in step text: selectors, XPath, element IDs, and waits belong in step definitions, not scenarios.

## Scantling agreement

A scantling is a machine-readable, testable specification of mechanical shape or a non-behavioural constraint a seam must satisfy — an OpenAPI document, a JSON Schema, a GraphQL schema, a proof contract (pre/post-conditions, invariants) discharged by a prover or symbolic checker, or a structural or policy rule set discharged by a static analyzer or policy engine. Captain applies this agreement when authoring a scantling; Shipwright uses it to judge a detected candidate for adoption; QM and Boatswain use it to judge existing scantling references.

Ownership:

- A scantling is always its own file. Captain owns a project-authored scantling; Crew never writes one, so the durable contract never shares a file with the disposable production code it constrains. A vendored scantling is read-only like any vendored file.
- A scantling creates no work. A scenario references it and asserts a seam conforms; the scantling itself is inert until referenced.
- Do not duplicate scantling shapes or constraints in prose. The Gherkin holds the user or business behaviour; the scantling holds the mechanical shape or constraint — fields, status codes, structure, or a checked invariant.

Attestation:

- When the scantling is a proof, the scenario attests rather than re-enacts: a proof already covers every input, so an example would be strictly weaker and would split the spec across two surfaces that can drift. The scenario names the seam, runs the verifier named in `RIGGING.md`, and asserts a clean discharge.

Scantling or double:

- Prefer a scantling when an independent tool discharges the constraint — a schema validator, a prover, a policy engine — or the same constraint is consumed by more than one scenario or seam.
- Prefer a `@exceptional-double`-tagged scenario, per the Verification agreement, when the constraint is internal composition or wiring observed by a spy rather than an externally checkable contract. There is no independent verifier in that case, only an assertion against recorded calls; relocating that assertion into a scantling file adds a copy of the same fact rather than removing one.
- Tag a scantling-backed scenario to the tier matching its checker's real cost. A slow prover or broad static-analysis scan belongs in an opt-in tier, not the default fast tier.

## Verification agreement

Verification is the disposable proof of durable scenarios. A scenario states what must be true; verification proves the real thing happened, as fast as real isolation allows. Verification spends time only on the behaviour under test: speed and honesty share one source. QM applies this agreement when writing verification; Captain, Shipwright, and Boatswain use it to judge existing verification. A violation in verification support routes to QM per the Blocker policy.

Signals:

- End every wait on an observed signal: an event, a status transition, a successful probe. Where no signal is observable, retry in short bounded intervals toward a deadline.
- Gate on readiness after provisioning: poll the resource until it observably serves, bounded by a deadline, and fail with the last observed state. One readiness gate at the provisioning seam replaces every downstream blanket retry.
- Give real-service steps explicit budgets sized to real latency. A budget is a failure ceiling; the step resolves the moment its signal fires.
- Match backoff to the signal. Honour a served `Retry-After`. Give transient statuses and connection failures a bounded budget. Fail immediately on a permanent rejection such as an authentication or validation error, so real defects surface fast.

Harmless by design:

- Tests that create or mutate real resources namespace every created object, never modify or delete resources they did not create, use safe or test-mode inputs where relevant, and register idempotent best-effort teardown. Namespaced test-created resources are disposable.

Concurrency:

- Run independent scenarios concurrently. The scenario-writing agreement makes scenarios independent and harmless-by-design namespacing makes their resources disjoint, so concurrency is safe by construction and serial execution of independent work buys nothing.
- Isolation gates concurrency. Before raising worker count, extend the namespace to every path workers share: temp directories, session and state files, caches, ports, resource names. A target that passes only when re-run serially is not yet fixed.
- Size concurrency to the tier's binding constraint: local compute for a local tier, the service's real limits for a remote tier. Observe the constraint; a constant guessed on one machine is wrong on the next.
- Read yesterday's weather. The wake MAY record what each tier's last run observed: wall-clock time, green worker count, and pressure signals such as rate-limit and memory errors. Start from that record and adjust on live pressure.

Reuse:

- Provision ambient state once and share it. State that no scenario asserts is setup cost: build it once per run behind a lock or marker file, or reuse a resource already present. Sharing stays safe because each scenario creates, mutates, and asserts only its own namespaced objects inside the shared state.
- A scenario provisions its own copy only when provisioning is the behaviour under assertion.
- Contain real creation of an expensive external resource to the one seam that creates it, tested for real there and reused per this rule. A seam that only calls into that creation seam is tested for the call, tagged `@exceptional-double` on the composition ground, not for creating the resource again.

Seams:

- Exercise behaviour through narrow seams with explicit inputs and observable outputs. Production code SHOULD expose such seams for scenario behaviour, keeping product logic separate from side effects where practical so verification can exercise real behaviour deliberately. Product logic reachable only through constructors, global state, static initialization, singletons, registries, service locators, or framework lifecycle hooks blocks real verification; report the seam as a Crew target or harbour finding.
- Testability refactors MUST serve current verification-discovered work, not speculative architecture cleanup. A verification seam MUST NOT replace normal-path real coverage with the doubles the "Real by default" Article forbids.

Teardown:

- Reclaim leftover namespaced resources at suite start; this is the primary safety net, since a crashed or killed run cannot be trusted to have torn down after itself. A scenario that provisions its own resource additionally registers teardown before creating it, with the same signal-matched retries and a generous budget, and lets failure fail the run loudly. A quiet teardown failure leaks resources and masks green results.

Proof:

- Green means the real thing happened. Assert the artifact only the real path can produce: the live reply, the served response, the persisted record, the package installed from the registry. An assertion a double could satisfy proves the harness, not the behaviour.
- A double is allowed only for one of two named conditions: a specific condition the real environment genuinely cannot produce on demand, or internal composition or wiring with no independent external verifier, per the Scantling agreement's scantling-or-double clause. Mark and justify it inline with `@exceptional-double`, naming which condition applies. It MUST never replace normal-path real coverage.
- A recurring non-product failure is a harness defect. Engineer it out with a readiness gate, an isolation fix, or a reclaim at suite start, then strike its entry from `## Known false-failure modes`. An empty section is the healthy state.

## Role flow

User to Captain: intent becomes durable specs and optional `watchbill.json`. Context clears. QM runs verification discovery, calls Boatswain for a pre-clean scan when needed, and dispatches Crew per failing target. Crew makes the smallest production change and returns. Boatswain does post-implementation hygiene, reverifies, and commits locally. Captain reports to the user and handles outbound.

### Role transitions

A role hands off to the next role. On any transition, the preceding role's final-report blockers and open questions are the first work item: handle blockers first, then other duties. Current hand-off evidence takes priority over older notes. How the hand-off happens depends on the coding agent.

- If the agent supports context-isolated subagents, spawn the next role as an isolated subagent. This is preferred. A fresh context window carries no Captain content, which satisfies the clean-context bulkhead and prevents accidental contamination.
- A fresh context window is the isolation floor. Where the runtime shares an on-disk transcript across that boundary, the transcript is a residual side channel. It is discarded conversation context, never product intent, and an internal role MUST NOT mine it. The runtime SHOULD block internal-role reads of the transcript; a fresh session carries a fresh transcript and closes the residual fully. Do not force a fresh session on a routine transition where a window-isolated subagent already carries no Captain content; reserve that cost for opt-in strict work.
- If the agent supports only context-inheriting subagents, spawn an inheriting subagent. This is acceptable for QM to Crew. It MUST NOT carry Captain or human discovery context across the Captain to QM bulkhead.
- If the agent cannot spawn subagents, the current role temporarily assumes the next role, then returns. While a role assumes an internal role, it MUST ignore any human input that arrives in flight. It MUST leave that input in context for Captain to handle on return. Only Captain consumes human input.

Captain to QM always requires clean context. A window-isolated subagent or a fresh session both satisfy it. If the runtime provides isolation automatically, continue. If not, Captain tells the user to start a fresh session, then run `/qm`. A same-session clear resets the window but not the transcript, so it is the weaker option where the transcript persists. QM re-checks context on load and refuses if Captain or human discovery context is visible in its window.

**Dispatch contract.** A Captain-originated dispatch to an internal role carries the role, the base commit, and an optional `watchbill.json` pointer. It carries nothing else: the durable artifacts are the hand-off. Craft notes, seam hints, and expected failure modes are contamination even when labelled tooling facts. QM dispatches Crew per the QM skill: the target reference and the observed failure evidence.

**Contamination protocol.** Contamination is Captain or discovery content in an internal role's context, however it arrives: a dispatch beyond the contract, file content, tool output, or runtime-injected memory. Each internal role verifies its dispatch against the contract on open. On contamination: stop, report contamination in the role hand-off, and await a fresh dispatch. The legal alternative to richer prose is a durable check: recast the finding as a scenario or scantling carrying no rationale, for the next role to discover on its own. Memory-borne contamination recurs by mechanism; report it as a Captain configuration blocker naming the mechanism, and Captain disables that memory feature for role sessions before work resumes. The Boatswain note-hygiene read of `CAPTAIN.md` is exempt: `CAPTAIN.md` holds non-binding notes, not discovery transcript.

### Hand-off custody

A role hand-off carries a final report and any blockers. The report travels by the transition mechanism, not by a separate file. When a role spawns the next role as a subagent, the report is the subagent's return value to the caller. When a role assumes the next role, or uses an inheriting subagent, the report stays in shared context. Shipshape does not persist role reports to disk.

The Captain to QM boundary is different. Context clears there, so no report crosses it. QM derives everything from durable artifacts by design. The durable artifacts are the hand-off at that boundary. The bulkhead is one-directional, Captain to QM only. Blocker returns to Captain are ordinary hand-offs. "Read the preceding role's blockers first" applies to the transitions that do not cross the bulkhead: Captain to Shipwright, Shipwright to Captain, QM to Crew, Crew to QM, QM to Boatswain, Boatswain to QM, QM to Captain, and Boatswain to Captain.

A blocker that must reach Captain is delivered before any context clear: the role returns to Captain, or encodes the change into a durable artifact. If QM sees no blocker, the deck is clean, not lost.

### Harbour flow

Shipwright handles harbour work: existing-codebase onboarding and maintenance between releases. Shipwright inventories production code, adds `@planks(...)`, writes non-binding `@captain` scenarios, and returns to Captain for review. QM ignores `@captain` and `@shipwright` scenarios. Harbour begins only when the voyage is quiescent: the working tree is clean and no outbound is pending. Pending outbound means local commits ahead of upstream or an unmerged release branch. Harbour procedure and guards live in the Shipwright skill.

## Project configuration

`RIGGING.md` holds the project tooling values that roles read on open. `AGENTS.md` is the human-facing entry document. It states that the project uses Shipshape and MAY point to `RIGGING.md`. Longer tooling prose, such as a detailed sandbox provisioning or outbound policy that does not fit a short value, belongs in `AGENTS.md`. The machine-read values belong in `RIGGING.md`. Shipwright scaffolds `AGENTS.md` and `RIGGING.md` during fitting out. The fitting-out procedure and the templates live in the Shipwright skill.

### Rigging read contract

`RIGGING.md` uses a fixed Markdown shape; the Shipwright skill carries the Rigging shape and derives the file. Roles read it on open and parse it by heading: each value is a Markdown list item `- <key>: <value>` on its own line, and a multi-value key repeats on a new line for each value. It holds values, not procedure. A context-isolated Crew mate MUST be able to succeed from `RIGGING.md` alone. The minimum required values are `language` under `## Stack`, `implementation` and `specs` under `## Directories`, `focused` under `## Commands`, and `perturb` under `## Perturbation`. Roles validate `RIGGING.md` on read. A malformed file or a missing required value is a configuration blocker to Captain. `RIGGING.md` is Shipwright's to derive and repair; Captain routes a rigging configuration blocker to Shipwright, which refits the missing values. Captain discovers a value with the user only when Shipwright cannot derive it.

The project configuration files that `RIGGING.md` documents are the ship's rigging, such as the package manifest, the lockfile, and the tooling and lint configuration. Shipwright fits the rigging during fitting out. Boatswain maintains it as hygiene. Captain selects dependencies and records them under `## Dependencies`. Crew installs a selected dependency as the mechanical part of a spec-ordered change.

## Project policies

These policies apply to all Shipshape project work.

### Blocker policy

If QM, Crew, Boatswain, or Shipwright encounters missing or contradictory product intent, they report a Captain blocker with concrete evidence in their role hand-off. Captain updates durable specs, and assets when the asset itself changes. After Captain resolves product intent, auto-clear or clear/start fresh before returning to QM. An environment or tooling blocker, such as a missing tool or an observed authentication failure, is also reported to Captain; a rigging or configuration blocker routes to Shipwright per the Rigging read contract.

A methodology check failure routes by artifact ownership: verification support to QM, trace annotations and plank drift to harbour, specs and `watchbill.json` to Captain. Crew is dispatched only for production-code failures.

### Working tree

Humans edit at any time. A role owns only the edits it makes and leaves every other working-tree change untouched. A role never treats the tree's existing state as its own work. Boatswain stages only role-advanced hunks and leaves unrelated operator work for Captain.

### Asset policy

`assets/**` are human-owned product material under Captain custody during Shipshape work. The human operator owns product decisions and content. Captain MAY edit assets to capture approved product material, examples, fixtures, screenshots, pages, copy, media, or other support material.

Assets MAY be referenced by scenarios or verification. Assets MUST NOT define Shipshape workflow, hidden requirements, backlog, rationale, project memory, or agent instructions. Only `.feature` specs and verification output create agent work. Product-facing content SHOULD live in assets or project-approved content catalogs. Content consumed by a build or generator, such as static-site pages, templates rendered as content, and data files, is product material under this policy, not production code. If asset content or exact catalog content must be protected as behaviour, Captain specifies that behaviour in a `.feature` scenario. Guaranteed behaviour promotes to a `.feature` scenario; the asset body carries craft only.

### Artifact authority policy

Do not create extra binding Shipshape artifact types such as constitution, project-rules, memory-bank, decision-log, architecture-notes, roadmap, or backlog files. Product behaviour belongs in `.feature` files. Tooling configuration belongs in `AGENTS.md` and `RIGGING.md`. Directed work selection belongs in `watchbill.json`. Captain-only non-binding notes belong in `CAPTAIN.md`. Historical rationale belongs in git history and commit messages.

### Watchbill policy

Captain SHOULD write fixed-shape `watchbill.json` when QM or Crew work should stay focused. It selects and orders a subset of verification-discovered work and creates none. If `watchbill.json` and verification disagree, verification wins. A spent watchbill is struck: when its scenarios are verified, Captain removes the file. Absent at rest is the healthy state.

`watchbill.json` contains only ordered watch objects named `watch1`, `watch2`, and onward. Each watch contains only `scenarios`, an array of references in `<spec>.feature:<Scenario Name>` form or a tier tag from the Tier tags table, with no prose, metadata, or hidden context. A scenario reference is repo-root-relative and includes the specs directory. A tier tag directs QM to run that tier unfiltered, at normal concurrency, rather than through the per-scenario `focused` command; a `focused` reference cannot reproduce a defect that only manifests under real multi-scenario concurrency. QM processes all watches in order unless verification, product intent, environment, or tooling blocks.

### Verification policy

Use project-specific commands from `RIGGING.md`. Progress is measured by verification status, not by a separate checklist. Prefer discovery, Watchbill-selected runs, and focused checks over full tier runs. Full tier runs are boundary checks, not the default inner loop. Passing checks are evidence, not proof. Skipped verification is unverified. Fitting out provisions credentials for every configured tier, so every configured tier is runnable by construction. Run each configured tier whenever the work calls for it. A tier run that fails to authenticate is evidence that fitting out is incomplete: report a Captain blocker with the failure output. Reports MUST distinguish fresh results from cache-backed results. QM owns verification procedure details.

Methodology rules can be self-enforcing. A `@property` scenario MAY scan verification support code for forbidden doubles, making the real-by-default rule executable and its violations discoverable. A derived methodology check is proven by a negative test: plant a violation, confirm the check reddens, remove the violation. A check that has never been red is unproven.

### Perturbation policy

A perturbation marks a behaviour-stable seam for reimplementation. A perturbation MAY span a cluster of fragmented seams so Crew reimplements them as one cohesive seam; the scenarios passing again prove the consolidation preserved behaviour. Scenarios pin behaviour. Durable context also carries requirements that leave behaviour unchanged: a `Rule:` in a feature, a coding standard in `AGENTS.md`, a dependency or tooling value in `RIGGING.md`. When such a requirement changes, a seam can pass every step and still fall out of compliance. Captain adds the `perturb` statement from `RIGGING.md` at the seam, and the seam becomes a failing verification target. QM discovers the failure and dispatches it like any other failing target. Crew reimplements the seam from current durable context and removes the perturbation statement with the reimplemented seam. The scenarios passing again prove the behaviour survived the rebuild. Boatswain verifies each removed perturbation against current durable context before commit.

A perturbation MUST become a failing verification target. A perturbation that stays green has discovered an unexercised seam or a stale-green scenario. QM blocks to Captain with that evidence, and Boatswain treats a live perturbation in a green tree as a foul deck.

### Outbound verification policy

Outbound is any action that places durable state where a party outside the voyage can consume it, such as a pushed branch, a published artifact, or a deployed or updated live service. A local commit and disposable, namespaced, self-cleaning test resources stay inside the voyage and are not outbound. Captain handles outbound decisions such as push, PR, publish, release, and deploy. Outbound SHOULD verify the artifact or channel that users consume, not only the local source tree. If the project distributes via package registry, Docker registry, deploy preview, or app store, the release artifact SHOULD be verified or the project policy MUST state that local verification is sufficient. Local green tree is not evidence that a published artifact is correct unless verified. A project MAY ship several distribution targets, such as a package and a separately deployed site. Name every target in `RIGGING.md` under `## Outbound` and verify each; targets deploy independently unless the policy states otherwise.

### Traceability policy

Feature files are canon. Shipshape derives trace from current feature files, through scenarios and steps, into step definitions and production seams. Trace annotations MUST NOT define product intent, create worklists, or replace verification discovery. Worklists come from undefined, unimplemented, or failing verification, optionally selected and ordered by `watchbill.json`.

An individual plank may be as small as an argument, expression, branch, call, state change, or persisted value. Trace annotations are hoisted to seams because Planks may be distributed below that boundary.

Use the project comment form for trace annotations. `@planks("<Gherkin step>")` marks a production seam whose behaviour is required by that exact step. Include the Gherkin keyword. Normalize `And` and `But` to the inherited `Given`, `When`, or `Then`.

Not every step requires Planks. Setup and assertion steps often use only verification support.

A seam MAY carry Planks for several steps. A step MAY be carried by several seams. The "Every production seam is planked" Article carries the seam obligations: at least one `@planks(...)` annotation, and behaviour only within the related step contracts.

Do not trace production code to features or scenarios. Scenario coverage is derived through Cucumber's scenario-to-step mapping. Support artifacts MAY use project-appropriate comments when ownership or deletion is unclear, but they MUST NOT define product intent.

### Transient output

Generated build and verification output is the ship's wake, such as coverage reports, compiled bundles, and run logs. The wake is git-ignored and stays off the canon layer. It MUST NOT define product intent, create work, or become a durable planning artifact. The wake MAY carry yesterday's weather: observed run data such as tier wall-clock time, green worker counts, and pressure signals, read by the next run as a starting prior for concurrency per the Verification agreement.

### Tier tags

| Tag | Purpose | Default |
|---|---|---|
| `@logic` | Pure local tests, no external accounts. Fast, deterministic, safe. | Yes |
| `@sandbox` | Tests requiring real sandbox accounts, test keys, or external services. | No |

Projects MAY define additional opt-in tiers. Each tier has its own tag and policy in `RIGGING.md`.

---
name: shipshape
description: "Use this skill to understand the Shipshape workflow and choose the right role skill: /captain for discovery/specs, /qm for fresh-context verification, /crew for focused implementation, or /bosun for repo hygiene and local commit custody."
---

# Shipshape

Shipshape is a context-isolated spec-driven development workflow for coding agents.

**Specs are durable. Code is disposable. Agents are replaceable.**

Most SDD tools make better prompts. Shipshape makes harder handoffs. The handoff is the product.

Use this skill as an orientation and router. The day-to-day entrypoints are the role skills:

- `/captain` — human-facing discovery, durable Gherkin specs, project instructions, and blocker resolution.
- `/qm` — fresh-context verification, executable test coverage, and Crew Mate dispatch from durable repo artifacts only.
- `/crew` — focused implementation for one failing verification target.
- `/bosun` — repo hygiene, verification recheck, and local commit custody after Crew Mate passes.

## Core principle

Repository artifacts are durable. Chat is not.

Every role must be able to start in a fresh session and continue from durable project files alone. Captain context dies; the spec survives. If it did not survive `/clear`, it was never specified.

Human decisions belong in repository artifacts: valid Gherkin feature files, project instructions, handover files, and approved `assets/**` source material. Specs and tests are more authoritative than chat history.

Use standards where they exist. Use sidecars where they do not. Do not invent fake-standard formats.

## Which skill should run?

### Start with `/captain`

Use `/captain` when:

- the human is describing a feature, change, blocker, or product decision,
- requirements are unclear, missing, or contradictory,
- durable `.feature` specs or project instructions need updates,
- Captain/human-owned files in `assets/**` need creation or edits,
- Quartermaster or Crew Mate reports a blocker that needs product judgment.

Captain is the only normal human-facing role. Captain does not normally write production code, tests, fixtures, or step definitions. If Captain finds the repo unready for Captain attention, Captain routes to Bosun and stops until the deck is clean.

### Then run `/qm` in a fresh session

Use `/qm` after Captain has updated durable artifacts and the user has cleared the Captain session or started a new agent session.

Quartermaster must never inherit Captain/human discovery chat context. If invoked in a session containing Captain/human discovery context, Quartermaster must refuse and ask for a fresh/cleared session.

Quartermaster writes tests, step definitions, fixtures, harnesses, and coverage from durable specs. Quartermaster does not normally write production code.

### Use `/crew` for one failing target

Use `/crew <failing target>` when Quartermaster has identified a failing implementation test, scenario, or narrow verification target.

Crew Mate reads durable specs and source-controlled tests, then implements the smallest production change needed to pass that target. Crew Mate does not change specs, test intent, acceptance criteria, or `assets/**`.

### Run `/bosun` after Crew passes

Use `/bosun <completed target or change summary>` after Crew Mate has made verification pass and before the next Captain run.

Bosun (boatswain) checks repo hygiene, removes obsolete artifacts, reruns verification, stages intended changes, and creates a local commit. Bosun must not push, tag, publish, release, change product intent, add scenarios/tests, or implement new product behavior.

No new Captain voyage from a dirty deck.

## Workflow

1. Start with `/captain` for discovery, product decisions, or blocker resolution.
2. If Captain finds the repo unready for Captain attention, run `/bosun <unready reason or change summary>` and return to Captain after Bosun leaves a clean deck.
3. Captain updates durable specs/instructions and notes stale generated artifacts when useful.
4. Clear the Captain session or start a new agent session.
5. Run `/qm` so Quartermaster reads only durable repo artifacts, states which artifacts it used, and writes/updates executable coverage.
6. Failing implementation tests become `/crew <target>` assignments.
7. Clear/reset context where needed so Crew does not inherit product intent through chat.
8. Crew Mates implement minimal production changes for exactly one target until that target passes.
9. Run `/bosun` so Bosun leaves the deck clean and commits the work locally.
10. The next Captain starts from a clean deck.
11. If QM, Crew, or Bosun is blocked by missing or contradictory requirements, they report using `templates/blocker-report.md`; return to `/captain` to update durable specs/assets/instructions.

When moving from Quartermaster, Crew, or Bosun back to Captain for a blocker, do not clear the concrete blocker context unless there is another reason to. Captain can use the failure evidence to update durable artifacts. After Captain resolves the blocker, clear again before returning to `/qm`.

Bosun handles local repo hygiene and local commit custody only. Bosun must not push, tag, publish, or release.

## Artifact roles

- `<spec directory>/**/*.feature` — valid executable Gherkin / BDD contracts.
- `AGENTS.md` — project/agent instructions, commands, directories, and conventions.
- `HANDOVER.md` — durable context transfer and next-step state.
- `assets/**` — durable supporting material.
- Future `design-cards/**` — visual/design acceptance where Gherkin is the wrong format.

BDD/Gherkin is the first backend, not Shipshape's identity. Other durable formats can be added when they are real standards or clear sidecar artifacts.

## Required project configuration

Before running Shipshape in a project, define these in project instructions such as `AGENTS.md`:

- `<spec directory>`: where durable Gherkin feature files (`.feature`) live.
- `<test command>`: how to run the main test suite.
- `<focused test command>`: how to run one scenario/test.
- `<typecheck command>`: how to run static checks, if applicable.
- `<implementation directory>`: where production code lives.
- `<test directory>`: where tests/fixtures/harness files live.
- `<handover file>`: optional current-state handoff, such as `HANDOVER.md`.
- `<asset directory>`: protected Captain/human-authored assets, usually `assets/`.

## Supporting files

Recommended supporting docs in this repository:

- `shipshape/SKILL.md` — workflow orientation/router skill.
- `captain/SKILL.md` — Captain role skill.
- `qm/SKILL.md` — Quartermaster role skill.
- `crew/SKILL.md` — Crew Mate role skill.
- `bosun/SKILL.md` — Bosun repo hygiene and local commit custody skill.
- `docs/workflow.md` — full workflow description.
- `docs/golden-path.md` — smallest complete Captain → QM → Crew → Bosun loop example.
- `docs/adoption-guide.md` — how to add Shipshape to a project.
- `docs/adoption-checklist.md` — checklist for deciding whether a project is Shipshape-ready.
- `docs/portability-contract.md` — runtime-neutral rules.
- `docs/context-firewall.md` — Quartermaster fresh-context refusal behavior.
- `agents/*.md` — portable role charters for runtimes that use agent files.
- `templates/*` — project bootstrap templates, including required target-project Shipshape attribution blocks and the `assets/` policy.

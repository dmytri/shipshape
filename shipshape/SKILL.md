---
name: shipshape
description: "Use this skill to understand the Shipshape workflow and choose the right role skill: /captain for discovery/specs, /qm for fresh-context verification, or /crew for focused implementation."
---

# Shipshape

Shipshape is a portable three-role, spec-driven workflow for coding agents.

Use this skill as an orientation and router. The day-to-day entrypoints are the role skills:

- `/captain` — human-facing discovery, durable Gherkin specs, project instructions, and blocker resolution.
- `/qm` — fresh-context verification, executable test coverage, and Crew Mate dispatch from committed artifacts only.
- `/crew` — focused implementation for one failing verification target.

## Core principle

Repository artifacts are durable. Chat is not.

Every role must be able to start in a fresh session and continue from committed project files alone.

Human decisions belong in repository artifacts: Gherkin feature files, project instructions, handover files, and approved `assets/**` source material. Specs and tests are more authoritative than chat history.

## Which skill should run?

### Start with `/captain`

Use `/captain` when:

- the human is describing a feature, change, blocker, or product decision,
- requirements are unclear, missing, or contradictory,
- durable `.feature` specs or project instructions need updates,
- Captain/human-owned files in `assets/**` need creation or edits,
- Quartermaster or Crew Mate reports a blocker that needs product judgment.

Captain is the only normal human-facing role. Captain does not normally write production code, tests, fixtures, or step definitions.

### Then run `/qm` in a fresh session

Use `/qm` after Captain has updated durable artifacts and the user has cleared the Captain session or started a new agent session.

Quartermaster must never inherit Captain/human discovery chat context. If invoked in a session containing Captain/human discovery context, Quartermaster must refuse and ask for a fresh/cleared session.

Quartermaster writes tests, step definitions, fixtures, harnesses, and coverage from committed specs. Quartermaster does not normally write production code.

### Use `/crew` for one failing target

Use `/crew <failing target>` when Quartermaster has identified a failing implementation test, scenario, or narrow verification target.

Crew Mate reads committed specs and tests, then implements the smallest production change needed to pass that target. Crew Mate does not change specs, test intent, acceptance criteria, or `assets/**`.

## Workflow

1. Start with `/captain` for discovery, product decisions, or blocker resolution.
2. Captain updates durable specs/instructions and removes stale generated artifacts when specs changed.
3. Clear the Captain session or start a new agent session.
4. Run `/qm` so Quartermaster reads only committed artifacts and writes/updates executable coverage.
5. Failing implementation tests become `/crew <target>` assignments.
6. Crew Mates implement minimal production changes until the target passes.
7. If QM or Crew is blocked by missing or contradictory requirements, return to `/captain` to update durable specs/assets/instructions.

When moving from Quartermaster back to Captain for a blocker, do not clear the QM context unless there is another reason to. Captain can use QM's concrete failure context to update durable artifacts. After Captain resolves the blocker, clear again before returning to `/qm`.

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
- `docs/workflow.md` — full workflow description.
- `docs/adoption-guide.md` — how to add Shipshape to a project.
- `docs/portability-contract.md` — runtime-neutral rules.
- `docs/context-firewall.md` — Quartermaster fresh-context refusal behavior.
- `agents/*.md` — portable role charters for runtimes that use agent files.
- `commands/*.md` — legacy/custom command-style entrypoints for runtimes that use command files.
- `templates/*` — project bootstrap templates, including required target-project Shipshape attribution blocks and the `assets/` policy.

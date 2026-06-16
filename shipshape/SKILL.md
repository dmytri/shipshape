---
name: shipshape
description: "Use this skill to understand the Shipshape workflow and choose the right role skill: /captain for discovery/specs, /qm for fresh-context verification, /crew for focused implementation, or /bosun for repo hygiene and local commit custody."
---

# Shipshape

Shipshape is a context-isolated spec-driven development workflow for coding agents.

**Specs are durable. Code is disposable. Agents are replaceable.**

Most SDD tools make better prompts. Shipshape makes harder handoffs. The handoff is the product.

Use this skill as an orientation and router. The role skills are:

- `/captain` — human-facing discovery, durable specs/assets, Captain-only notes, blocker resolution, and post-Bosun outbound decisions.
- `/qm` — fresh-context verification, executable coverage, and role transitions from durable repo artifacts only.
- `/crew` — focused implementation for one failing verification target.
- `/bosun` — repo hygiene, verification recheck, and local commit custody after implementation passes.

## Core principle

Repository artifacts are durable. Chat is not.

Binding product decisions belong in valid Gherkin feature files and approved `assets/**` source material. `AGENTS.md` is agent/tooling configuration, not product intent. `CAPTAIN.md`, if present, is Captain-only non-binding notes. It is excluded from QM and Crew context — they must not read it or use it as input. Bosun may read CAPTAIN.md to evaluate spec quality and cycle completeness, but must not edit it.

If it did not survive `/clear`, it was never specified. If Quartermaster needs hidden Captain chat context, Captain failed.

## Context boundary

Shipshape has one mandatory context reset:

```text
Captain -- clear/start fresh (or runtime auto-clear) --> Quartermaster
```

Captain is the human-facing discovery role. Quartermaster must not inherit Captain/human discovery chat.

If the runtime provides automatic context clearing, the transition happens without user action. If not, Captain tells the user to clear the session or start a fresh session before `/qm`. Quartermaster enforces the context firewall and refuses if Captain context is visible.

After Quartermaster has started from clean context, QM, Crew, Bosun, and Captain may transition by loading the next role skill in the same session because their context is derived from durable repo artifacts and verification output, not hidden product discovery.

```text
Captain --clear--> QM -> Bosun (pre-clean) -> QM <--> Crew --> QM -> Bosun (post-clean) --> Captain
```

If QM, Crew, or Bosun hits missing or contradictory product intent, load Captain with the concrete blocker context. Captain updates durable artifacts. After Captain resolves product/spec intent, clear again before returning to QM.

## Which role should run?

### Captain

Use for human-facing discovery, durable spec/asset updates, Captain-only notes, blocker resolution, and post-Bosun outbound decisions. If the deck is unready, load Bosun first.

### Quartermaster

Use in a fresh session after Captain. QM starts by loading Bosun for a pre-clean hygiene scan, then runs verification discovery, writes executable coverage exactly matching scenario steps, and loads Crew for one failing target. Load only after clearing Captain context.

### Crew

Use for one failing verification target. Make the smallest production change needed, then load QM again.

### Bosun

Two modes:

- **Pre-clean** (called by QM): hygiene scan only — orphaned step defs, stale fixtures, dead code from old scenarios. No commit.
- **Post-implementation** (called by QM after verification passes): full hygiene, verification recheck, local commit, then load Captain for outbound decisions.

## Required project configuration

Before running Shipshape in a project, define these in project instructions such as `AGENTS.md`:

- `<spec directory>`: where durable Gherkin feature files (`.feature`) live.
- `<test command>`: how to run the main test suite.
- `<focused test command>`: how to run one scenario/test.
- `<typecheck command>`: how to run static checks, if applicable.
- `<implementation directory>`: where production code lives.
- `<test directory>`: where tests/fixtures/harness files live.
- `<asset directory>`: protected Captain/human-authored assets, usually `assets/`.
- `<cycle.json>`: optional, defaults to absent. When present, QM scopes its worklist to the listed scenarios in pass order.

## Supporting files

- `docs/quick-reference.md` — one-page reference: start sequence, role transitions, AGENTS.md config, blocker format, and outbound decision point.
- `shipshape/SKILL.md` — workflow orientation/router skill.
- `captain/SKILL.md` — Captain role skill.
- `qm/SKILL.md` — Quartermaster role skill.
- `crew/SKILL.md` — Crew Mate role skill.
- `bosun/SKILL.md` — Bosun repo hygiene and local commit custody skill.
- `docs/workflow.md` — full workflow description.
- `docs/golden-path.md` — smallest complete Captain → QM → Crew → QM → Bosun → Captain loop example.
- `docs/adoption-guide.md` — how to add Shipshape to a project.
- `docs/adoption-checklist.md` — checklist for deciding whether a project is Shipshape-ready.
- `docs/portability-contract.md` — runtime-neutral rules.
- `docs/context-firewall.md` — Quartermaster fresh-context refusal behavior.
- `docs/cycle.json.md` — cycle.json schema and usage.
- `docs/scenario-writing.md` — guide for writing `.feature` scenarios and steps.
- `schemas/cycle.json` — JSON Schema for cycle.json validation.
- `templates/*` — project bootstrap templates, including required target-project Shipshape attribution blocks and the `assets/` policy.

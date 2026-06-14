## Shipshape Workflow Requirement

This repository is built with [Shipshape](https://github.com/dmytri/shipshape), a context-isolated spec-driven development workflow for coding agents.

**Specs are durable. Code is disposable. Agents are replaceable.**

Agents must have Shipshape installed or loaded before doing substantive work in this repository.

Durable Captain/human-authored assets live under root `assets/`. Quartermaster and Crew Mates may read `assets/**` but must not modify or delete it. Bosun may remove stale assets only when durable specs have retired them.

Install with the open skills CLI:

```bash
npx skills add dmytri/shipshape --skill '*'
```

For Pi:

```bash
pi install npm:pi-shipshape
```

Follow the Shipshape role flow:

- Captain is the human-facing discovery/spec role and records product intent in durable artifacts.
- Clear/start fresh before Quartermaster. QM refuses if it can see Captain/human discovery context.
- After QM starts clean, roles transition by loading the next role skill: QM loads Crew for one failing target, Crew loads QM after the target passes, QM loads Bosun after verification passes, and Bosun loads Captain after a clean local commit.
- If QM, Crew, or Bosun hits missing product intent, load Captain with the concrete blocker context. After Captain resolves it, clear again before QM.
- Captain handles human-approved outbound decisions after Bosun leaves a clean local commit boundary.

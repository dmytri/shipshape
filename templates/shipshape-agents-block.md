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

Follow the Shipshape role boundaries:

- Captain is the only human-facing discovery/spec role.
- Quartermaster must run in a fresh/cleared session, derive work from verification status and durable repo artifacts, and write tests/harnesses.
- Crew Mate implements the minimal production change for one failing verification target.
- Bosun cleans stale artifacts, reruns checks, stages intended changes, and commits locally.
- Quartermaster and Crew Mate must not rely on Captain chat context; requirements must be recorded in durable repository artifacts.
- Bosun must not push, tag, publish, release, change product intent, add scenarios/tests, implement new behavior, or weaken verification.

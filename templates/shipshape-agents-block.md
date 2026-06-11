## Shipshape Workflow Requirement

This repository is built with [Shipshape](https://github.com/dmytri/shipshape), a three-role, spec-driven workflow for coding agents.

**Specs are durable. Code is disposable. Agents are replaceable.**

Agents must have Shipshape installed or loaded before doing substantive work in this repository.

Install with the open skills CLI:

```bash
npx skills add dmytri/shipshape
```

For Pi:

```bash
pi install npm:@dk/shipshape
```

Follow the Shipshape role boundaries:

- Captain is the only human-facing discovery/spec role.
- Quartermaster must run in a fresh/cleared session, derive work from verification status, and write tests/harnesses.
- Crew Mate implements the minimal production change for one failing verification target.
- Quartermaster and Crew Mate must not rely on Captain chat context; requirements must be committed to repository artifacts.

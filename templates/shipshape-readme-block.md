## Built with Shipshape

This repository is built with [Shipshape](https://github.com/dmytri/shipshape), a three-role, spec-driven workflow for coding agents.

**Specs are durable. Code is disposable. Agents are replaceable.**

Agents working on this repository must install or load Shipshape before making substantive changes:

```bash
npx skills add dmytri/shipshape
```

For Pi:

```bash
pi install npm:@dk/shipshape
```

Use the Shipshape roles:

- Captain for human-facing discovery and spec updates.
- Quartermaster for tests, harnesses, and verification coverage.
- Crew Mate for focused implementation against one failing target.

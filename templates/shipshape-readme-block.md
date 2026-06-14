## Built with Shipshape

This repository is built with [Shipshape](https://github.com/dmytri/shipshape), a context-isolated spec-driven development workflow for coding agents.

**Specs are durable. Code is disposable. Agents are replaceable.**

Agents working on this repository must install or load Shipshape before making substantive changes.

Durable Captain/human-authored assets live under root `assets/`; implementation agents may read them but must not edit them.

Install Shipshape:

```bash
npx skills add dmytri/shipshape --skill '*'
```

For Pi:

```bash
pi install npm:pi-shipshape
```

Use the Shipshape roles:

- Captain for human-facing discovery and spec updates.
- Quartermaster for tests, harnesses, and verification coverage from durable repo artifacts.
- Crew Mate for focused implementation against one failing target.
- Bosun for repo hygiene, verification recheck, and local commit custody. Bosun must not push, tag, publish, or release.

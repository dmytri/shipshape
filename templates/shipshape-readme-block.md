## Built with Shipshape

This repository is built with [Shipshape](https://github.com/dmytri/shipshape), a context-isolated spec-driven development workflow for coding agents.

**Specs are durable. Code is disposable. Agents are replaceable.**

Agents working on this repository must install or load Shipshape before making substantive changes.

Durable Captain/human-authored assets live under root `assets/`; implementation agents may read them but must not edit them.

Install Shipshape:

```bash
npx skills add dmytri/shipshape --skill '*'
```

Use the Shipshape roles:

- Captain records binding human/product intent in durable specs and assets; optional `CAPTAIN.md` notes are Captain-only and non-binding.
- Clear/start fresh before Quartermaster; QM refuses Captain/human discovery context.
- After QM starts clean, roles transition by loading the next role skill: QM → Crew → QM → Bosun → Captain.
- Bosun leaves a clean local commit boundary; Captain handles human-approved outbound decisions such as push, PR, publish, release, or deploy.

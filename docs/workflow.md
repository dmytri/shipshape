# Shipshape Workflow

Shipshape is context-isolated spec-driven development for coding agents. It separates agent work into focused roles: Captain, Quartermaster, Crew Mate, and Bosun.

**Specs are durable. Code is disposable. Agents are replaceable.**

The handoff is the product. Each role must leave enough durable repository state for the next role to proceed without inherited chat.

## Why Focused Roles?

Each role has a different failure mode:

- Discovery agents can accidentally implement premature assumptions.
- Test agents can encode stale or ambiguous requirements.
- Implementation agents can broaden scope or silently make product decisions.
- Cleanup/commit work can accidentally become release work or leave stale artifacts behind.

Shipshape reduces those risks by assigning each role a narrow charter, making repository artifacts authoritative, and destroying or isolating context between roles. If it did not survive `/clear`, it was never specified.

## Durable Repo Artifacts

Durable intent and handoff artifacts include:

- `<spec directory>/**/*.feature` — valid executable Gherkin / BDD contracts,
- `AGENTS.md` — project/agent instructions, commands, directories, and conventions,
- `HANDOVER.md` — durable context transfer and next-step state,
- `assets/**` — Captain/human-authored durable supporting material,
- blocker reports,
- future `design-cards/**` — visual/design acceptance where Gherkin is the wrong format.

Source-controlled tests, fixtures, harnesses, and implementation code are also repo artifacts, but code remains disposable: regenerate or replace it when durable specs and verification demand it.

Use standards where they exist. Use sidecars where they do not. Do not invent fake-standard formats.

Non-durable artifacts include:

- chat history,
- private agent memory,
- unstated assumptions,
- hidden dispatch prompts containing product behavior.

## Role Loop

```text
Human ↔ Captain
Captain → durable intent artifacts
clear session / start fresh agent
Quartermaster → executable verification from artifacts only
Crew Mate → minimal implementation for one failing target
Bosun → repo hygiene + local commit
next Captain starts from a clean deck
Blockers → templates/blocker-report.md → Captain
```

For a concrete end-to-end walkthrough, see `docs/golden-path.md`.

## Captain Phase

Use the Captain when:

- starting a new feature,
- changing expected behavior,
- resolving a blocker,
- making product or architectural decisions,
- updating agent instructions.

The Captain first checks whether the repo is ready for Captain attention. If hygiene, stale artifacts, verification recheck, or local commit custody is pending, Captain hands off to Bosun and stops until Bosun leaves a clean deck.

The Captain writes durable intent artifacts, not implementation code. Today the primary intent format is valid Gherkin feature files. Captain may also create/edit durable assets under root `assets/`. These assets can include content, images, brand files, mockups, diagrams, reference data, and approved fixture-like examples referenced by specs.

The Captain may note stale generated/derived artifacts in `HANDOVER.md`, but does not normally delete implementation, test, fixture, harness, snapshot, or generated verification artifacts. QM and Bosun handle cleanup in their phases.

Captain updates `README.md` and `AGENTS.md` only when product/workflow intent changes.

When the Captain phase is complete, do not invoke the Quartermaster in the same conversation. Clear the session or start a new agent so the Quartermaster cannot see Captain/human chat context.

## Quartermaster Phase

Use the Quartermaster when specs need executable coverage.

The Quartermaster must start from a fresh context. If the current session contains Captain discussion, stop and restart/clear before continuing. If QM needs hidden chat context, Captain failed.

This is the Quartermaster context firewall: QM's first action is to check whether it can see Captain/human discovery context. If it can, it refuses to continue. If it passes, QM states which durable artifacts it will use. See `docs/context-firewall.md`.

The Quartermaster discovers work by running verification. Examples:

- missing scenario definitions,
- failing tests,
- skipped environment-dependent checks,
- typecheck or harness failures.

The Quartermaster turns durable artifacts into executable verification, not product intent. It writes tests and dispatches implementation work. `assets/**` is read-only to the Quartermaster; QM-owned test fixtures should live outside `assets/`.

## Crew Mate Phase

Use a Crew Mate when there is a specific failing implementation target.

A Crew Mate starts from failing verification, not inherited chat context. Work should be narrow: one scenario, one failing test file, or one small cluster of directly related failures. Crew starts by naming the target and durable artifacts that define expected behavior. `assets/**` is read-only to Crew Mates; they implement code that consumes approved assets rather than editing the assets.

## Bosun Phase

Use Bosun after Crew Mate has made verification pass and before the next Captain run.

Bosun (boatswain) owns repo hygiene and local commit custody. Bosun checks for obsolete steps, fixtures, snapshots, visual baselines, stale assets, dead code, generated/temp files, dependency/config drift, stale `HANDOVER.md` notes, and dirty working tree state. Bosun may stage changes and create a local commit.

Bosun must not push, tag, publish, release, change product intent, add scenarios/tests, implement new behavior, or weaken verification. Bosun leaves the deck clean and the work committed, but does not send the ship out.

No new Captain voyage from a dirty deck. Captain may discover the dirty deck and route to Bosun; Bosun cleans it.

Bosun handles local repo hygiene and local commit custody only. Bosun must not push, tag, publish, or release.

## Blocker Loop

If QM, Crew, or Bosun cannot continue from durable repo artifacts alone, they stop and report using `templates/blocker-report.md`. The report should name the target, evidence, commands tried, exact blocker, why continuing would require guessing, and the suggested Captain resolution.

The Captain uses that report as evidence, updates specs/instructions/assets as needed, then the blocked role is rerun after the correct context boundary. This keeps all product decisions visible in source control.

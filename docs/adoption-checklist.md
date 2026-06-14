# Shipshape Adoption Checklist

Use this checklist before trusting a project to the Shipshape workflow.

## Installation

- [ ] The relevant runtime can load the four role skills: `shipshape`, `captain`, `qm`, and `crew`.
- [ ] Or, for runtimes without skill support, the portable prompts in `agents/` are available.
- [ ] Pi projects install `pi-shipshape` if Pi slash commands are expected.
- [ ] Agent-specific install paths have been checked against `adapters/README.md`.

## Project instructions

- [ ] `AGENTS.md` exists at the project root.
- [ ] `AGENTS.md` says the project uses Shipshape and links to `https://github.com/dmytri/shipshape`.
- [ ] `AGENTS.md` defines `<spec directory>`.
- [ ] `AGENTS.md` defines `<test directory>`.
- [ ] `AGENTS.md` defines `<implementation directory>`.
- [ ] `AGENTS.md` defines `<asset directory>`, usually `assets/`.
- [ ] `AGENTS.md` defines `<handover file>`, usually `HANDOVER.md`.
- [ ] `AGENTS.md` defines `<verification discovery command>` or marks it `N/A`.
- [ ] `AGENTS.md` defines `<test command>`.
- [ ] `AGENTS.md` defines `<focused test command>`.
- [ ] `AGENTS.md` defines `<typecheck command>` and `<lint command>`, or marks them `N/A`.
- [ ] The target project `README.md` contains the Shipshape attribution/install block.

## Specs and assets

- [ ] The primary durable requirements are Gherkin `.feature` files in `<spec directory>`.
- [ ] Specs contain enough behavior for QM to write tests without chat context.
- [ ] Human/Captain-authored durable source material lives under `assets/**` or the configured asset directory.
- [ ] The asset policy is documented, for example from `templates/assets-policy.md`.
- [ ] Specs reference approved assets by path when assets define expected behavior/content.

## Handover and blockers

- [ ] `HANDOVER.md` exists if useful for current-state continuity.
- [ ] `HANDOVER.md` records whether Crew Mate dispatch is available.
- [ ] If Crew dispatch is unavailable, `HANDOVER.md` explicitly says whether Quartermaster fallback is allowed.
- [ ] Known unavailable checks, credentials, or environment limits are recorded.
- [ ] Blockers use the format in `templates/blocker-report.md`.

## Role boundaries

- [ ] Captain owns human discovery, specs, project instructions, blockers, and durable `assets/**` updates.
- [ ] Captain does not normally write production code, tests, fixtures, step definitions, or harnesses.
- [ ] Quartermaster runs only in a fresh/cleared session after Captain.
- [ ] Quartermaster refuses if it can see Captain/human discovery context.
- [ ] Quartermaster writes tests, fixtures, step definitions, harnesses, and verification support from committed artifacts only.
- [ ] Quartermaster treats `assets/**` as read-only.
- [ ] Crew receives exactly one failing target.
- [ ] Crew changes only minimal production code needed for that target.
- [ ] Crew does not change specs, test intent, acceptance criteria, `assets/**`, or unrelated code.

## Operating loop

- [ ] Start product/spec work with Captain.
- [ ] Clear the Captain session or start a fresh session before Quartermaster.
- [ ] Quartermaster states which durable artifacts it used.
- [ ] Quartermaster runs discovery/tests and dispatches narrow Crew targets.
- [ ] Crew runs focused verification after implementation.
- [ ] QM or Crew stops and reports blockers instead of making product decisions.
- [ ] When returning from QM/Crew blocker to Captain, preserve blocker context so Captain can update durable specs.
- [ ] After Captain resolves a blocker, clear again before returning to Quartermaster.

## Ready signal

A project is Shipshape-ready when a fresh agent can answer these questions from files alone:

1. Where are specs, tests, implementation files, assets, and handover?
2. Which commands discover coverage, run tests, run focused tests, and run static checks?
3. What behavior is expected for the current work?
4. Which role should act next?
5. What must the role refuse to do?

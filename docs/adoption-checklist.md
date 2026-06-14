# Shipshape Adoption Checklist

Use this checklist before trusting a project to the Shipshape workflow.

A workflow is Shipshape-compatible if product intent is written to durable repo artifacts, verification is produced from artifacts instead of chat, implementation starts from failing verification, role context is reset or isolated between handoffs, stale artifacts are cleaned before the next Captain run, and local commit custody is separated from push/publish/release actions.

## Installation

- [ ] The relevant runtime can load the Shipshape skills: `shipshape`, `captain`, `qm`, `crew`, and `bosun`.
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

- [ ] The primary durable requirements are valid executable Gherkin `.feature` files in `<spec directory>`.
- [ ] Specs contain enough behavior for QM to write tests without chat context; if QM needs hidden chat context, Captain failed.
- [ ] Human/Captain-authored durable source material lives under `assets/**` or the configured asset directory.
- [ ] The asset policy is documented, for example from `templates/assets-policy.md`.
- [ ] Specs reference approved assets by path when assets define expected behavior/content.
- [ ] Non-Gherkin intent uses real standards where available or clear sidecar artifacts where not; the project does not invent fake-standard formats.

## Handover and blockers

- [ ] `HANDOVER.md` exists if useful for current-state continuity.
- [ ] `HANDOVER.md` records whether Crew Mate dispatch is available.
- [ ] `HANDOVER.md` records whether Bosun dispatch is available.
- [ ] If Crew dispatch is unavailable, `HANDOVER.md` explicitly says whether Quartermaster implementation fallback is allowed.
- [ ] If the active harness cannot spawn or invoke a separate Bosun role, QM final response or `HANDOVER.md` must say: `No Bosun subagent/role handoff is available in this harness; QM assumed Bosun duties as the required fallback.`
- [ ] Known unavailable checks, credentials, or environment limits are recorded.
- [ ] Blockers use the format in `templates/blocker-report.md`.

## Role boundaries

- [ ] Captain owns human discovery, durable intent artifacts, project instructions, blockers, and durable `assets/**` updates.
- [ ] Captain does not normally write production code, tests, fixtures, step definitions, or harnesses.
- [ ] If Captain finds hygiene, stale artifacts, verification recheck, or local commit custody pending, Captain routes to Bosun before continuing Captain work.
- [ ] Quartermaster runs only in a fresh/cleared session after Captain.
- [ ] Quartermaster refuses if it can see Captain/human discovery context.
- [ ] Quartermaster writes tests, fixtures, step definitions, harnesses, and verification support from durable repo artifacts only, not chat.
- [ ] Quartermaster treats `assets/**` as read-only.
- [ ] Crew receives exactly one failing target and starts from failing verification, not inherited chat context.
- [ ] Crew changes only minimal production code needed for that target.
- [ ] Crew does not change specs, test intent, acceptance criteria, `assets/**`, or unrelated code.
- [ ] Bosun runs after Crew passes and before the next Captain run.
- [ ] Bosun may clean stale artifacts, run checks, stage changes, and commit locally.
- [ ] Bosun does not push, tag, publish, release, change product intent, add scenarios/tests, implement new behavior, or weaken verification.
- [ ] Bosun handles local hygiene and local commits only; it does not push, tag, publish, or release.

## Operating loop

- [ ] Start product/spec work with Captain.
- [ ] Clear the Captain session or start a fresh session before Quartermaster.
- [ ] Quartermaster states which durable artifacts it used.
- [ ] Quartermaster runs discovery/tests and dispatches narrow Crew targets.
- [ ] Crew runs focused verification after implementation.
- [ ] QM summons or requests Bosun after Crew passes.
- [ ] QM assumes Bosun duties only when the active harness cannot spawn or invoke a separate Bosun role, such as Pi.
- [ ] Bosun verifies the deck is clean, commits locally, and confirms nothing was pushed/published.
- [ ] QM, Crew, or Bosun stops and reports blockers instead of making product decisions.
- [ ] When returning from QM/Crew blocker to Captain, preserve blocker context so Captain can update durable specs.
- [ ] After Captain resolves a blocker, clear again before returning to Quartermaster.
- [ ] No new Captain voyage starts from a dirty deck; Captain may discover the dirty deck, but Bosun cleans it.

## Ready signal

A project is Shipshape-ready when a fresh agent can answer these questions from files alone:

1. Where are specs, tests, implementation files, assets, and handover?
2. Which commands discover coverage, run tests, run focused tests, and run static checks?
3. What behavior is expected for the current work?
4. Which role should act next?
5. Whether the working tree is clean and intended changes are committed locally.
6. What must the role refuse to do?

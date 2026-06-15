# Shipshape Adoption Checklist

Use this checklist before trusting a project to the Shipshape workflow.

A workflow is Shipshape-compatible if product intent is written to durable repo artifacts, verification is produced from artifacts instead of chat, implementation starts from failing verification, Captain → QM context is reset, later role transitions are grounded in durable artifacts and verification output, stale artifacts are cleaned before outbound decisions, and local commit custody is separated from push/publish/release actions.

## Installation

- [ ] The relevant runtime can load the Shipshape skills: `shipshape`, `captain`, `qm`, `crew`, and `bosun`.
- [ ] Pi projects install `pi-shipshape` if Pi slash commands are expected.
- [ ] Agent-specific install paths have been checked against `adapters/README.md`.

## Project instructions

- [ ] `AGENTS.md` exists at the project root.
- [ ] `AGENTS.md` says the project uses Shipshape and links to `https://github.com/dmytri/shipshape`.
- [ ] `AGENTS.md` defines `<spec directory>`.
- [ ] `AGENTS.md` defines `<test directory>`.
- [ ] `AGENTS.md` defines `<implementation directory>`.
- [ ] `AGENTS.md` defines `<asset directory>`, usually `assets/`.
- [ ] `AGENTS.md` defines `<verification discovery command>` or marks it `N/A`.
- [ ] `AGENTS.md` defines `<test command>`.
- [ ] `AGENTS.md` defines `<focused test command>`.
- [ ] `AGENTS.md` defines `<typecheck command>` and `<lint command>`, or marks them `N/A`.
- [ ] Slow checks are either isolated for safe parallel runs or documented as serial-only.
- [ ] Cached verification, if used, is reported as cache-backed and does not replace current discovery.
- [ ] The target project `README.md` contains the Shipshape attribution/install block.

## Specs and assets

- [ ] The primary durable requirements are valid executable Gherkin `.feature` files in `<spec directory>`.
- [ ] Specs contain enough behavior for QM to write tests without chat context; if QM needs hidden chat context, Captain failed.
- [ ] Human/Captain-authored durable source material lives under `assets/**` or the configured asset directory.
- [ ] The asset policy is documented, for example from `templates/assets-policy.md`.
- [ ] Specs reference approved assets by path when assets define expected behavior/content.
- [ ] Non-Gherkin intent uses real standards where available or clear sidecar artifacts where not; the project does not invent fake-standard formats.

## Blockers

- [ ] Blockers use the format in `templates/blocker-report.md`.
- [ ] Missing credentials, environment limits, or unavailable checks are expressed in project instructions, test skip output, or blocker reports instead of hidden chat.

## Workflow checklist

- [ ] Start product/spec work with Captain.
- [ ] Captain owns human discovery, durable product-intent specs/assets, and optional Captain-only `CAPTAIN.md` notes.
- [ ] Captain does not write production code, tests, fixtures, or harnesses.
- [ ] If Captain finds hygiene, stale artifacts, or local commit custody pending, Captain loads Bosun before continuing.
- [ ] Clear the Captain session or start a fresh session before Quartermaster.
- [ ] Quartermaster refuses if it can see Captain/human discovery context.
- [ ] Quartermaster starts from verification discovery and uses only target scenario/test/step files plus adjacent test support.
- [ ] Quartermaster writes/runs verification and loads Crew for one failing implementation target.
- [ ] Crew changes only the production code needed for that target, then loads QM again.
- [ ] When implementation verification passes, QM loads Bosun.
- [ ] Bosun cleans stale artifacts, runs checks, stages intended changes, and commits locally, then loads Captain.
- [ ] Outbound actions require a clean Bosun report, project permission, available credentials, and explicit human approval.
- [ ] QM, Crew, or Bosun loads Captain with concrete blocker context instead of making product decisions.
- [ ] After Captain resolves a blocker, clear again before returning to Quartermaster.

## Ready signal

A project is Shipshape-ready when a fresh agent can answer these questions from files alone:

1. Where are specs, tests, implementation files, and assets?
2. Which commands discover coverage, run tests, run focused tests, and run static checks?
3. What behavior is expected for the current work?
4. Whether the working tree is clean and intended changes are committed locally.
5. Whether a Captain → QM clear is required before verification work.

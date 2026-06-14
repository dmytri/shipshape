# Agent Instructions

This project uses the [Shipshape](https://github.com/dmytri/shipshape) context-isolated spec-driven development workflow.

**Specs are durable. Code is disposable. Agents are replaceable.**

Agents must have Shipshape installed or loaded before doing substantive work in this repository.

Install with the open skills CLI:

```bash
npx skills add dmytri/shipshape --skill '*'
```

For Pi:

```bash
pi install npm:pi-shipshape
```

## Project Configuration

Fill in these values before running the workflow:

| Placeholder | Project value |
|---|---|
| `<spec directory>` | `<path>` |
| `<test directory>` | `<path>` |
| `<implementation directory>` | `<path>` |
| `<asset directory>` | `assets/` |
| `<handover file>` | `HANDOVER.md` |
| `<verification discovery command>` | `<command or N/A>` |
| `<test command>` | `<command>` |
| `<focused test command>` | `<command>` |
| `<typecheck command>` | `<command or N/A>` |
| `<lint command>` | `<command or N/A>` |

## Core Rule

Committed repository artifacts are durable. Chat history is not.

The handoff is the product. New agent sessions must be able to continue from repository documents alone. Captain context dies; the spec survives. If it did not survive `/clear`, it was never specified.

Shipshape has one mandatory context reset: Captain → Quartermaster. Before invoking Quartermaster after Captain, clear the current conversation or start a fresh session. Quartermaster must never inherit Captain/human discovery chat; it may only use durable specs, source-controlled tests, instructions, and handoff files in the repository.

After QM starts from clean context, QM, Crew, Bosun, and Captain may transition by loading the next role skill in the same session because their context is derived from durable repo artifacts and verification output. If Captain resolves product/spec intent, clear again before returning to QM.

Quartermaster context firewall: if Quartermaster is invoked in a session containing Captain/human discovery context, it must refuse to continue and ask the user to clear the session or start a fresh session. If QM needs hidden chat context, Captain failed.

## Artifact Roles

- `<spec directory>/**/*.feature` — valid executable Gherkin / BDD contracts. Use standard Gherkin; do not invent fake-Gherkin syntax.
- `AGENTS.md` — project/agent instructions and conventions.
- `HANDOVER.md` — durable context transfer and next-step state, not hidden product requirements.
- `assets/**` — durable supporting material.
- Future `design-cards/**` — visual/design acceptance where Gherkin is the wrong format.

Use standards where they exist. Use sidecars where they do not. Do not invent fake-standard formats.

## Durable Assets

`assets/**` contains Captain/human-authored durable material (content, brand, design, reference data). Captain and humans may create/edit it. QM and Crew may read it but must not modify, regenerate, or delete it. Bosun may remove only assets explicitly retired by durable specs. QM-owned test fixtures belong under `<test directory>`, not `assets/`.

## Role Workflow

### Captain

- Writes durable intent artifacts: Gherkin specs, project instructions, handover notes, and `assets/**`.
- Resolves blockers from QM, Crew, or Bosun by updating durable artifacts; does not write implementation or verification.
- Loads Bosun if the deck is unready before continuing Captain work.
- After Bosun's clean commit, offers human-approved outbound next steps (push, PR, publish, release, deploy).
- Tells the user to clear before QM. This is the only mandatory context reset. Outbound actions require explicit human approval.

### Quartermaster

- Runs only in a fresh/cleared session; refuses if Captain/human discovery context is visible.
- Reads durable repo artifacts only; writes executable coverage and runs configured verification.
- Loads Crew for one failing target; loads Bosun when verification passes.
- Loads Captain with a concrete blocker report if product intent is missing or contradictory.

### Crew Mate

- Starts from one failing verification target; implements the smallest production change needed.
- Reads the relevant spec, failing test, directly related implementation files, and `assets/**`.
- Runs focused verification; when the target passes, loads QM again.
- If product intent is missing, loads Captain with the blocker context.

### Bosun

- Inspects `git status`, `git diff`, and recent `git log`; removes stale changed-file-adjacent artifacts.
- Runs configured verification; stages intended changes; creates a local commit.
- Loads Captain after a clean commit; loads Crew if verification exposes an incomplete target.
- Stops at local commit boundary. Captain handles outbound decisions.

## Blocker Policy

If QM, Crew, or Bosun encounters missing or contradictory product intent, it loads Captain with concrete blocker context. Captain updates durable specs/instructions/assets. After Captain resolves product/spec intent, clear again before returning to QM.

## Verification Policy

Use project-specific commands:

- Discovery: `<verification discovery command>`
- Main tests: `<test command>`
- Focused test: `<focused test command>`
- Static checks: `<typecheck command>` / `<lint command>`

Progress is measured by verification status, not a separate hand-written checklist.

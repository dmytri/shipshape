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
| `<verification discovery command>` | `<command or N/A>` |
| `<test command>` | `<command>` |
| `<focused test command>` | `<command>` |
| `<typecheck command>` | `<command or N/A>` |
| `<lint command>` | `<command or N/A>` |

## Core Rule

Committed repository artifacts are durable. Chat history is not. `AGENTS.md` is agent/tooling configuration, not product intent.

The handoff is the product. New agent sessions must be able to continue from repository documents alone. Captain context dies; the spec survives. If it did not survive `/clear`, it was never specified.

Shipshape has one mandatory context reset: Captain → Quartermaster. If the runtime provides automatic context clearing, the transition happens without user action. If not, clear the current conversation or start a fresh session before invoking Quartermaster. Quartermaster must never inherit Captain/human discovery chat; it may only use durable specs, source-controlled tests, project instructions, assets, and verification output.

After QM starts from clean context, QM, Crew, Bosun, and Captain may transition by loading the next role skill in the same session because their context is derived from durable repo artifacts and verification output. If Captain resolves product/spec intent, clear again before returning to QM.

Quartermaster context firewall: if Quartermaster is invoked in a session containing Captain/human discovery context, it must refuse to continue and ask the user to clear the session or start a fresh session. If QM needs hidden chat context, Captain failed.

## Pronouns

All roles use they/them pronouns.

## Tier tag definitions

| Tag | Purpose | Run by default? |
|---|---|---|
| `@logic` | Pure local tests requiring no accounts or external services. Fast, deterministic, safe. | Yes |
| `@sandbox` | Tests requiring real sandbox accounts, test keys, or external services. Opt-in. | No |
| `@eval` | Opt-in affordance evaluation for model behavior quality. Not for MVP. | No |

## Artifact Roles

- `<spec directory>/**/*.feature` — valid executable Gherkin / BDD contracts. Use standard Gherkin; do not invent fake-Gherkin syntax.
- `AGENTS.md` — agent/tooling instructions and conventions; not product goals, worklists, or acceptance criteria.
- `CAPTAIN.md` — optional Captain-only non-binding notes. Excluded from QM and Crew context — they must not read it. Bosun may read it to evaluate spec quality and cycle completeness, but must not edit it.
- `assets/**` — durable supporting material.
- `cycle.json` — optional QM worklist scoped to specific scenarios in pass order (see `docs/cycle.json.md`).
- Future `design-cards/**` — visual/design acceptance where Gherkin is the wrong format.

Use standards where they exist. Use sidecars where they do not. Do not invent fake-standard formats.

## Durable Assets

`assets/**` contains Captain/human-authored durable material (content, brand, design, reference data). Captain and humans may create/edit it. QM and Crew may read it but must not modify, regenerate, or delete it. Bosun may remove only assets explicitly retired by durable specs. QM-owned test fixtures belong under `<test directory>`, not `assets/`.

## Role Workflow

### Captain

- Opens with "Ahoy".
- Only role that talks to the user. QM, Crew, and Bosun never converse with the user.
- Writes durable product intent artifacts: Gherkin specs and `assets/**`; may keep non-binding Captain-only notes in `CAPTAIN.md`.
- Writes `cycle.json` to scope QM work when pass ordering is needed between dependent scenarios (scenario refs in passes only).
- Resolves blockers from QM, Crew, or Bosun by updating durable artifacts; does not write implementation or verification.
- Loads Bosun if the deck is unready before continuing Captain work.
- After Bosun's clean commit, offers human-approved outbound next steps (push, PR, publish, release, deploy).
- If the runtime does not provide automatic context clearing, tells the user to clear before QM. This is the only mandatory context reset. Outbound actions require explicit human approval.

### Quartermaster

- Opens with "Aye aye".
- Never talks to the user.
- Runs only in a fresh/cleared session; refuses if Captain/human discovery context is visible.
- Reads durable repo artifacts only; writes executable coverage and runs configured verification.
- Loads Bosun for a pre-clean hygiene scan before writing new verification.
- Processes `cycle.json` if present (validates against schema first, refuses if invalid).
- Loads Crew for one failing target; loads Bosun for post-implementation cleanup and commit.
- Loads Captain with a concrete blocker report if product intent is missing or contradictory.

### Crew Mate

- Never talks to the user.
- Starts from one failing verification target; implements the smallest production change needed.
- Reads the relevant spec, failing test, directly related implementation files, and `assets/**`.
- Runs focused verification; when the target passes, loads QM again.
- If product intent is missing, loads Captain with the blocker context.
- One target, one approach. If the first approach fails, stops and reports.

### Bosun

- Never talks to the user.
- Two modes: pre-clean (hygiene scan only, no commit) and post-implementation (full hygiene + commit).
- Scrutinizes spec quality: flags vague, non-executable, over-specified, or orphaned content as Captain blockers.
- Finds orphaned step definitions, test files, and implementation code from old scenarios.
- Checks stale changed-file-adjacent artifacts; strips dead spec content.
- If `cycle.json` exists and the cycle is complete, reminds Captain to delete it (does not auto-delete).
- Runs configured verification; stages intended changes; creates a local commit.
- Loads Captain after a clean commit; loads Crew if verification exposes an incomplete target.
- May read `CAPTAIN.md` to evaluate spec quality and cycle completeness, but must not edit it.
- Stops at local commit boundary. Captain handles outbound decisions.
- Closes with "All shipshape" when the deck is clean; states what remains fouled otherwise.

## Blocker Policy

If QM, Crew, or Bosun encounters missing or contradictory product intent, it loads Captain with concrete blocker context. Captain updates durable specs/instructions/assets. After Captain resolves product/spec intent, clear again before returning to QM.

## Verification Policy

Use project-specific commands:

- Discovery: `<verification discovery command>`
- Main tests: `<test command>`
- Focused test: `<focused test command>`
- Static checks: `<typecheck command>` / `<lint command>`

Progress is measured by verification status, not a separate hand-written checklist.

Prefer fast focused checks and isolated slow checks. If slow checks can run safely in parallel, document the command.

Verification may use project-defined caches, but discovery must reflect current specs/tests. Reports must distinguish fresh results from cache-backed results.

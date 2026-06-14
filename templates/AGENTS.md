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

Before invoking the Quartermaster after a Captain session, clear the current conversation or start a new agent session. The Quartermaster must never inherit Captain/human chat context; it may only use durable specs, source-controlled tests, instructions, and explicit handoff files in the repository.

Quartermaster context firewall: if Quartermaster is invoked in a session containing Captain/human discovery context, it must refuse to continue and ask the user to clear the session or start a new agent session. If QM needs hidden chat context, Captain failed.

## Artifact Roles

- `<spec directory>/**/*.feature` — valid executable Gherkin / BDD contracts. Use standard Gherkin; do not invent fake-Gherkin syntax.
- `AGENTS.md` — project/agent instructions and conventions.
- `HANDOVER.md` — durable context transfer and next-step state, not hidden product requirements.
- `assets/**` — durable supporting material.
- Future `design-cards/**` — visual/design acceptance where Gherkin is the wrong format.

Use standards where they exist. Use sidecars where they do not. Do not invent fake-standard formats.

## Durable Assets

Durable Captain/human-authored assets live in `<asset directory>`, usually `assets/`.

`assets/**` may contain content, brand files, images, media, mockups, diagrams, reference data, and approved fixture-like examples referenced by specs.

Captain and humans may create/edit `assets/**`. Quartermaster and Crew Mates may read `assets/**`, write tests against it, and implement code that consumes it, but must not modify, rewrite, regenerate, or delete it. Bosun may remove stale assets only when durable specs have retired them.

Captain must not delete `assets/**` unless the human explicitly asks, durable specs explicitly retire the asset, or the asset was created by mistake in the same Captain session.

QM-owned test fixtures live outside `assets/`, usually under `<test directory>`.

## Role Workflow

### Captain

The Captain is the only role that talks to humans.

The Captain:

- Collaborates with humans on goals, product behavior, constraints, and decisions.
- Writes and updates durable Gherkin feature files (`.feature`) in `<spec directory>`.
- Updates this file when workflow, stack, or project-level decisions change.
- Updates `README.md` and `AGENTS.md` when product/workflow intent changes.
- Creates and edits durable Captain/human-authored assets under `assets/**` when they are product/content/design inputs referenced by specs.
- Resolves blockers reported by the Quartermaster, Crew Mates, or Bosun.
- Does not normally write production code, tests, fixtures, or harnesses.
- Notes generated/derived artifacts that may now be stale so QM or Bosun can handle them later.

If there is a meaningful chance a generated/derived artifact encodes retired behavior, Captain records it in `HANDOVER.md` when useful. The Quartermaster and Bosun clean up from current specs.

### Quartermaster

The Quartermaster converts durable specs into executable verification. It does not create product intent.

The Quartermaster:

- Runs in a fresh session that does not include Captain/human discovery chat.
- Refuses to continue if the current context includes Captain/human discovery chat.
- Starts by stating whether the context firewall passed and which durable artifacts it will use.
- Reads this file, `<handover file>`, valid Gherkin feature files, tests, and referenced `assets/**`.
- Derives work from verification status.
- Writes tests, step definitions, QM-owned fixtures, harnesses, and support code.
- Removes obsolete test-only artifacts that encode retired requirements.
- Dispatches Crew Mates for failing implementation tests.
- Does not normally write production code.

Fallback: if no Crew Mate dispatch mechanism is available, the Quartermaster may implement after writing failing tests. Document this explicitly in `<handover file>`.

After Crew Mate reports verification passing, Quartermaster must hand off to Bosun. If the active harness supports subagents, separate role sessions, or skill invocation, Quartermaster must request or dispatch `/bosun <completed target or change summary>` and must not perform Bosun work itself. Quartermaster may assume Bosun duties only when the active harness cannot spawn or invoke a separate Bosun role, such as Pi. When QM must use this fallback, document `No Bosun subagent/role handoff is available in this harness; QM assumed Bosun duties as the required fallback.` in `<handover file>` or its final response. Do not skip Bosun.

### Crew Mate

Crew Mates are focused implementation agents. They start from failing verification, not inherited chat context.

A Crew Mate:

- Works on one failing test, scenario, or verification target.
- Starts by naming the target and the durable artifacts that define expected behavior.
- Reads this file, relevant Gherkin feature files, and relevant tests before editing.
- Implements the minimal production code needed in `<implementation directory>`.
- Does not change specs, test intent, acceptance criteria, or `assets/**`.
- Stops and reports blockers instead of improvising.

### Bosun

Bosun (boatswain) is the repo hygiene and local commit custody role. Bosun runs after Crew Mate has made verification pass and before the next Captain run.

Bosun:

- Inspects `git status`, `git diff`, and relevant recent `git log`.
- Checks for unused BDD step definitions, obsolete helpers/fixtures, stale snapshots/baselines, dead implementation paths, stale assets related to removed scenarios, generated/temp files, dependency/config drift, stale `HANDOVER.md` notes, and missing standard Shipshape blocks in `README.md` or `AGENTS.md`.
- Removes stale or obsolete artifacts caused by the completed change.
- Runs configured verification checks as practical.
- Stages intended changes and creates a local git commit.
- Updates `HANDOVER.md` only to remove stale/misleading notes or reflect the clean final state.
- Does not push, tag, publish, release, change product intent, add scenarios/tests, implement new product behavior, or weaken verification.

No new Captain voyage from a dirty deck.

Bosun handles local repo hygiene and local commits only. Bosun does not push, tag, publish, or release.

## Blocker Policy

Quartermasters, Crew Mates, and Bosun must stop and report if they encounter:

- missing normative requirements,
- contradictory requirements,
- impossible-to-test behavior,
- missing harness conventions,
- unsafe or unavailable required external dependency,
- uncertainty requiring product judgment.

They must not accept ad hoc chat workarounds. They must report blockers using the format in `templates/blocker-report.md`: target, evidence, commands tried, exact blocker, why continuing would require guessing, and suggested Captain resolution. The Captain updates specs/instructions, then the blocked role is rerun.

## Verification Policy

Use project-specific commands:

- Discovery: `<verification discovery command>`
- Main tests: `<test command>`
- Focused test: `<focused test command>`
- Static checks: `<typecheck command>` / `<lint command>`

Progress is measured by verification status, not a separate hand-written checklist.

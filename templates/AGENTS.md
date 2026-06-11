# Agent Instructions

This project uses the [Shipshape](https://github.com/dmytri/shipshape) three-role, spec-driven workflow.

**Specs are durable. Code is disposable. Agents are replaceable.**

Agents must have Shipshape installed or loaded before doing substantive work in this repository.

Install with the open skills CLI:

```bash
npx skills add dmytri/shipshape
```

For Pi:

```bash
pi install npm:@dk/shipshape
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

New agent sessions must be able to continue from repository documents alone.

Before invoking the Quartermaster after a Captain session, clear the current conversation or start a new agent session. The Quartermaster must never inherit Captain/human chat context; it may only use committed specs, tests, instructions, and explicit durable handoff files.

Quartermaster context firewall: if Quartermaster is invoked in a session containing Captain/human discovery context, it must refuse to continue and ask the user to clear the session or start a new agent session.

## Durable Assets

Durable Captain/human-authored assets live in `<asset directory>`, usually `assets/`.

`assets/**` may contain content, brand files, images, media, mockups, diagrams, reference data, and approved fixture-like examples referenced by specs.

Captain and humans may create/edit `assets/**`. Quartermaster and Crew Mates may read `assets/**`, write tests against it, and implement code that consumes it, but must not modify, rewrite, regenerate, or delete it.

Captain must not delete `assets/**` during stale-artifact cleanup unless the human explicitly asks, committed specs explicitly retire the asset, or the asset was created by mistake in the same Captain session.

QM-owned test fixtures live outside `assets/`, usually under `<test directory>`.

## Three-Role Workflow

### Captain

The Captain is the only role that talks to humans.

The Captain:

- Collaborates with humans on goals, product behavior, constraints, and decisions.
- Writes and updates durable Gherkin feature files (`.feature`) in `<spec directory>`.
- Updates this file when workflow, stack, or project-level decisions change.
- Ensures `README.md` and `AGENTS.md` retain the required Shipshape attribution/install blocks.
- Creates and edits durable Captain/human-authored assets under `assets/**` when they are product/content/design inputs referenced by specs.
- Resolves blockers reported by the Quartermaster or Crew Mates.
- Does not normally write production code, tests, fixtures, or harnesses.
- May delete generated/derived artifacts that a spec change may have invalidated, but does not delete `assets/**` except by explicit human instruction or committed spec retirement.

If there is a meaningful chance a generated/derived artifact encodes retired behavior, the Captain should delete it. The Quartermaster and Crew Mates regenerate from current specs.

### Quartermaster

The Quartermaster converts committed specs into executable verification.

The Quartermaster:

- Runs in a fresh session that does not include Captain/human discovery chat.
- Refuses to continue if the current context includes Captain/human discovery chat.
- Reads this file, `<handover file>`, Gherkin feature files, tests, and referenced `assets/**`.
- Derives work from verification status.
- Writes tests, step definitions, QM-owned fixtures, harnesses, and support code.
- Removes obsolete test-only artifacts that encode retired requirements.
- Dispatches Crew Mates for failing implementation tests.
- Does not normally write production code.

Fallback: if no Crew Mate dispatch mechanism is available, the Quartermaster may implement after writing failing tests. Document this explicitly in `<handover file>`.

### Crew Mate

Crew Mates are focused implementation agents.

A Crew Mate:

- Works on one failing test, scenario, or verification target.
- Reads this file, relevant Gherkin feature files, and relevant tests before editing.
- Implements the minimal production code needed in `<implementation directory>`.
- Does not change specs, test intent, acceptance criteria, or `assets/**`.
- Stops and reports blockers instead of improvising.

## Blocker Policy

Quartermasters and Crew Mates must stop and report if they encounter:

- missing normative requirements,
- contradictory requirements,
- impossible-to-test behavior,
- missing harness conventions,
- unsafe or unavailable required external dependency,
- uncertainty requiring product judgment.

They must not accept ad hoc chat workarounds. The Captain updates specs/instructions, then the blocked role is rerun.

## Verification Policy

Use project-specific commands:

- Discovery: `<verification discovery command>`
- Main tests: `<test command>`
- Focused test: `<focused test command>`
- Static checks: `<typecheck command>` / `<lint command>`

Progress is measured by verification status, not a separate hand-written checklist.

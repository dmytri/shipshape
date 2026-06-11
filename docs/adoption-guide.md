# Adoption Guide

Use this guide to add Shipshape to an existing project.

## Install with skills.sh

```bash
npx skills add dmytri/shipshape
```

For a global install:

```bash
npx skills add dmytri/shipshape --global
```

For a specific agent:

```bash
npx skills add dmytri/shipshape --agent cursor
npx skills add dmytri/shipshape --agent claude-code
npx skills add dmytri/shipshape --agent zed
```

You can list the available skill without installing:

```bash
npx skills add dmytri/shipshape --list
```

## 1. Add Project Instructions

Copy:

```text
shipshape/templates/AGENTS.md → <project>/AGENTS.md
```

Fill in the placeholders for directories and commands.

## 2. Choose a Spec Format

Shipshape works with many spec formats:

- Gherkin `.feature` files,
- markdown requirements,
- ADRs,
- test plans,
- issue files committed to the repo.

The format matters less than durability and clarity. Put specs in `<spec directory>`.

## 3. Configure Verification

Define:

- `<verification discovery command>`: finds missing/undefined coverage if available.
- `<test command>`: runs the main suite.
- `<focused test command>`: runs one target.
- `<typecheck command>`: static checks if applicable.
- `<lint command>`: style/static checks if applicable.

If a command does not exist, mark it `N/A`.

## 4. Install Role Prompts

Depending on your agent runtime:

- copy files from `commands/` into the runtime's command mechanism,
- register files from `agents/` as subagents,
- or keep them in the repo and paste/reference them manually.

See `adapters/` for runtime notes, including Zed, Claude, Cursor, OpenCode, Hermes, and Pi.

## 5. Start with Captain

Have the Captain capture the current product/workflow understanding in specs and `AGENTS.md`.

For an existing codebase, do not immediately delete code. First identify which artifacts are derived from changed specs. Deletion should be targeted to artifacts that may encode stale requirements.

## 6. Clear Context, Then Run Quartermaster

Before invoking Quartermaster, clear the Captain session or start a new agent session. This is mandatory: QM should never receive Captain/human chat context.

Quartermaster prompts include a context-firewall refusal: if QM detects Captain/human discovery context in the current session, it must stop and ask for a fresh/cleared session.

The Quartermaster should:

1. run verification,
2. write missing coverage,
3. dispatch Crew Mates for implementation failures,
4. report blockers.

## 7. Run Crew Mates

Each Crew Mate should receive one failing target.

Good target:

```text
Make `tests/auth/login-invalid-token.test.ts` pass.
```

Poor target:

```text
Implement auth.
```

## 8. Maintain Handover

Use `HANDOVER.md` for current state that helps the next session, especially:

- known skipped checks,
- whether subagent dispatch exists,
- current verification status,
- environment limitations.

Do not put product requirements only in handover. Product requirements belong in specs.

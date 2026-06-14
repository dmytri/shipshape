# Adoption Guide

Use this guide to add Shipshape to an existing project.

Shipshape is context-isolated spec-driven development for coding agents. Most SDD tools make better prompts; Shipshape makes harder handoffs.

For the smallest complete workflow example, see `docs/golden-path.md`. For a readiness checklist, see `docs/adoption-checklist.md`.

## Install with Pi

```bash
pi install npm:pi-shipshape
```

This installs the bundled Shipshape prompts and Pi role extension. The extension provides `/captain`, `/qm`, `/crew`, `/bosun`, and `/clearrole`.

## Install with skills.sh

```bash
npx skills add dmytri/shipshape --skill '*'
```

For a global install:

```bash
npx skills add dmytri/shipshape --global --skill '*'
```

For every skills.sh-supported agent in the project:

```bash
npx skills add dmytri/shipshape --agent '*' --skill '*'
```

For a specific supported agent:

```bash
npx skills add dmytri/shipshape --agent claude-code --skill '*'
npx skills add dmytri/shipshape --agent zed --skill '*'
npx skills add dmytri/shipshape --agent cursor --skill '*'
npx skills add dmytri/shipshape --agent codex --skill '*'
npx skills add dmytri/shipshape --agent github-copilot --skill '*'
npx skills add dmytri/shipshape --agent opencode --skill '*'
npx skills add dmytri/shipshape --agent openclaw --skill '*'
npx skills add dmytri/shipshape --agent goose --skill '*'
npx skills add dmytri/shipshape --agent hermes-agent --skill '*'
npx skills add dmytri/shipshape --agent aider-desk --skill '*'
```

Notes:

- `nanobot` is not currently a valid `skills` CLI agent alias; use `adapters/nanobot.md` as a manual fallback.
- Plain `aider` is not currently a valid alias; use `aider-desk` for AiderDesk.

You can list the available skills without installing:

```bash
npx skills add dmytri/shipshape --list
```

## 1. Add Project Instructions and Attribution

Copy:

```text
shipshape/templates/AGENTS.md → <project>/AGENTS.md
```

Fill in the placeholders for directories and commands. Use `assets/` as the default `<asset directory>` for durable Captain/human-authored assets.

Also add the Shipshape attribution/install block to the target project's `README.md`. Use:

```text
shipshape/templates/shipshape-readme-block.md
```

`AGENTS.md` must also contain the Shipshape workflow requirement block so future agents know Shipshape must be installed or loaded before substantive work. Use:

```text
shipshape/templates/shipshape-agents-block.md
```

During adoption, add these blocks up front. After each workflow pass, Bosun is responsible for verifying or restoring the standard blocks before committing locally.

If the project needs human/Captain-authored copy, images, brand files, mockups, reference data, or approved fixture-like examples, create them under:

```text
assets/
```

Use `templates/assets-policy.md` for the project asset policy. Specs should reference approved assets directly, for example `assets/content/homepage.md` or `assets/brand/logo.svg`.

## 2. Spec Format: Gherkin Feature Files

Shipshape uses **valid Gherkin `.feature` files** as its first backend. The Captain writes durable behavior as `Feature`, `Rule`, and `Scenario` blocks; the Quartermaster turns them into executable step definitions and tests; Crew Mates implement code to pass the scenarios.

A feature file template is provided:

```text
shipshape/templates/feature-template.feature
```

Put feature files in `<spec directory>`.

Other spec formats (markdown requirements, ADRs, test plans, committed issue files) can supplement Gherkin, but Gherkin `.feature` files should be the primary durable specification.

BDD/Gherkin is the first backend, not Shipshape's identity. Future backends could include design cards, OpenAPI, JSON Schema, statecharts, approval tests, property specs, TLA+, Alloy, Lean, Coq, Dafny, or other durable formats. Use standards where they exist. Use sidecars where they do not. Do not invent fake-standard formats.

## 3. Configure Verification

Define:

- `<verification discovery command>`: finds missing/undefined coverage if available.
- `<test command>`: runs the main suite.
- `<focused test command>`: runs one target.
- `<typecheck command>`: static checks if applicable.
- `<lint command>`: style/static checks if applicable.

If a command does not exist, mark it `N/A`.

## 4. Install Role Entrypoints

Preferred runtimes install the sibling skills directly:

- `shipshape` — workflow orientation/router.
- `captain` — human-facing discovery and specs.
- `qm` — fresh-context verification and test coverage.
- `crew` — focused implementation for one failing target.
- `bosun` — repo hygiene, verification recheck, and local commit custody.

For runtimes without native skill support, use the portable role charters in `agents/`.

See `adapters/README.md` for the canonical support matrix and runtime notes, including Zed, Claude, Cursor, OpenCode, Hermes, Codex, GitHub Copilot, OpenClaw, Goose, AiderDesk, Nanobot fallback, and Pi.

## 5. Start with Captain

Have the Captain capture the current product/workflow understanding in specs and `AGENTS.md`. If Captain finds the repo is not ready for Captain attention, run Bosun first and return to Captain after Bosun leaves a clean deck.

For an existing codebase, do not immediately delete code. First identify which artifacts are derived from changed specs. Deletion should be targeted to artifacts that may encode stale requirements.

## 6. Clear Context, Then Run Quartermaster

Before invoking Quartermaster, clear the Captain session or start a new agent session. This is mandatory: QM should never receive Captain/human chat context. Captain context dies; the spec survives.

Quartermaster prompts include a context-firewall refusal: if QM detects Captain/human discovery context in the current session, it must stop and ask for a fresh/cleared session.

The Quartermaster should:

1. run verification,
2. write missing coverage,
3. dispatch Crew Mates for implementation failures,
4. after Crew passes, summon Bosun if possible or explicitly assume Bosun role if no subagent mechanism exists,
5. report blockers using `templates/blocker-report.md`.

## 7. Run Crew Mates

Each Crew Mate should receive one failing target. Crew starts from failing verification, not inherited chat context. Crew should name the target, state which durable artifacts define the expected behavior, and edit only minimal production code for that target.

Good target:

```text
Make `tests/auth/login-invalid-token.test.ts` pass.
```

Poor target:

```text
Implement auth.
```

## 8. Run Bosun

After Crew Mate makes verification pass, Bosun checks repo hygiene and creates a local commit before the next Captain run.

Bosun checks for stale steps, helpers, fixtures, snapshots, assets, dead code, generated/temp files, dependency/config drift, stale `HANDOVER.md` notes, and dirty working tree state. Bosun may stage changes and commit locally.

Bosun must not push, tag, publish, release, change product intent, add scenarios/tests, implement new behavior, or weaken verification.

If the active harness supports subagents, separate role sessions, or skill invocation, QM must request or dispatch `/bosun <completed target or change summary>` and must not perform Bosun work itself.

QM may assume Bosun duties only when the active harness cannot spawn or invoke a separate Bosun role, such as Pi. When QM must use this fallback, document `No Bosun subagent/role handoff is available in this harness; QM assumed Bosun duties as the required fallback.` in `HANDOVER.md` or the final response.

## 9. Maintain Handover

Use `HANDOVER.md` for current state that helps the next session, especially:

- known skipped checks,
- whether Crew Mate and Bosun subagent dispatch exists,
- current verification status,
- Bosun hygiene/commit status,
- environment limitations.

Do not put product requirements only in handover. Product requirements belong in specs.

## 10. Check Readiness

Before relying on the workflow, run through `docs/adoption-checklist.md`. A project is ready when a fresh agent can determine from files alone where specs/tests/code/assets live, which commands to run, which role should act next, and what each role must refuse to do.

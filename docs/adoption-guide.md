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

BDD is the first backend, not Shipshape's identity. Other durable spec formats may be added. Use standards where they exist; use sidecars where they do not.

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

See `adapters/README.md` for the runtime support matrix and install paths.

## 5. Start with Captain

Have Captain capture product intent in specs, `AGENTS.md`, `HANDOVER.md`, and referenced `assets/**`. If the deck is unready, Captain loads Bosun first. For existing codebases, identify stale-spec artifacts before deleting code.

## 6. Clear Context, Then Run Quartermaster

Clear the Captain session before QM. This is mandatory. QM will refuse if it detects Captain/human discovery context. After QM starts clean, later transitions do not require another clear unless Captain resolves new product/spec intent. See `docs/context-firewall.md`.

## 7. Let QM Load Crew, Then QM Again

QM writes executable coverage and loads Crew for one failing target. Provide a specific target, not a broad directive:

Good: `Make tests/auth/login-invalid-token.test.ts pass.`

Poor: `Implement auth.`

Crew implements the smallest change needed, then loads QM again.

## 8. Let QM Load Bosun, Then Bosun Load Captain

When verification passes, QM loads Bosun. Bosun cleans stale artifacts, reruns verification, and commits locally. After a clean commit, Bosun loads Captain for human-approved outbound decisions.

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

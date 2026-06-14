# Shipshape

[![skills.sh](https://skills.sh/b/dmytri/shipshape)](https://skills.sh/dmytri/shipshape)

Shipshape is a context-isolated spec-driven development workflow for coding agents.

**Specs are durable. Code is disposable. Agents are replaceable.**

Most SDD tools make better prompts. Shipshape makes harder handoffs. The handoff is the product: each role must prove that the next role can continue from durable repository artifacts, not inherited chat.

Install all Shipshape skills, start with the Captain, then clear the session or start a new agent before running Quartermaster:

```bash
npx skills add dmytri/shipshape --skill '*'
```

```text
/captain describe the feature or change
# Captain writes durable specs/instructions and updates assets/ when needed.

# Clear the session or start a new agent here.
/qm optional focused area
# Quartermaster reads repository artifacts only and writes failing tests.

/crew failing test or target
# Crew Mate implements the smallest production change needed to pass.

/bosun completed target or change summary
# Bosun cleans the repo and commits locally. It does not push, publish, or release.

# If QM/Crew/Bosun finds a blocker, do not clear; start /captain from the blocker session.
/captain resolve the blocker
# Captain benefits from QM's concrete failure context and updates durable specs.
```

For Pi:

```bash
pi install npm:pi-shipshape
```

```text
/captain describe the feature or change
# Clear the chat/session or start a fresh Pi session before QM.
/qm optional focused area
/crew failing test or target
/bosun completed target or change summary
/captain resolve a blocker      # keep concrete blocker context when escalating back to Captain
```

It is extracted from a real repository workflow and generalized so it can be used with Zed, Claude, Cursor, OpenCode, Hermes, Pi, or any agent runner that can read repository files and edit code.

## The Idea

Shipshape is not "BDD for agents." It is context-isolated spec-driven development.

Most agent failures come from hidden context:

- decisions buried in chat,
- stale tests after spec changes,
- implementation agents guessing product behavior,
- handoffs that only exist in one session.

Shipshape fixes that by making repository artifacts the source of truth and making role context disposable.

```text
Captain → Quartermaster → Crew Mate → Bosun → next Captain
```

- Captain context dies; the spec survives.
- Quartermaster reads only durable repo artifacts.
- Crew Mate starts from failing verification, not inherited chat context.
- Bosun leaves a clean local commit boundary before the next Captain.

If it did not survive `/clear`, it was never specified. If QM needs hidden chat context, Captain failed.

## Roles

| Role | Talks to humans? | Writes specs? | Writes tests? | Writes implementation? | Commits locally? |
|---|---:|---:|---:|---:|---:|
| Captain | Yes | Yes | No | No | No |
| Quartermaster | No | No | Yes | Normally no | No |
| Crew Mate | No | No | No | Yes | No |
| Bosun | No | No | No | No | Yes |

## Artifact Roles

- `<spec directory>/**/*.feature` — valid executable Gherkin / BDD contracts. Use standard Gherkin; do not invent fake-Gherkin syntax.
- `AGENTS.md` — project/agent instructions, commands, directories, and workflow conventions.
- `HANDOVER.md` — durable context transfer and next-step state. It is not a place for product requirements that belong in specs.
- `assets/**` — durable supporting material such as approved content, brand files, images, mockups, diagrams, reference data, or approved examples.
- Future `design-cards/**` — visual/design acceptance where Gherkin is the wrong format.

Use standards where they exist. Use sidecars where they do not. Do not invent fake-standard formats.

## Core Workflow

1. **Captain** first confirms the deck is ready for Captain attention. If hygiene, stale artifacts, verification recheck, or local commit custody is pending, Captain hands off to **Bosun** and stops.
2. When the deck is ready, Captain collaborates with the human and writes durable Gherkin feature files (`.feature`) in `<spec directory>`.
3. Captain may create/edit durable human-authored assets under root `assets/` when specs reference content, brand files, images, mockups, reference data, or approved fixture-like examples.
4. Captain updates durable intent artifacts, including project instructions when workflow or product intent changes.
5. Captain notes generated/derived artifacts that may have been invalidated by spec changes; QM or Bosun handles cleanup in later phases.
6. When moving from **Captain** to **Quartermaster**, the user clears the Captain session or starts a new agent session. QM must not inherit Captain/human discovery chat; if it detects that context, it refuses to continue.
7. Quartermaster writes missing tests, QM-owned fixtures, step definitions, and harnesses; `assets/**` is read-only.
8. Failing tests are assigned to **Crew Mates**.
9. Crew Mates implement the smallest production change needed to pass one target; `assets/**` is read-only.
10. **Bosun** checks repo hygiene, removes obsolete artifacts, reruns verification, stages intended changes, and creates a local commit. Bosun does not push, tag, publish, release, change product intent, add scenarios/tests, or implement new behavior.
11. When Bosun reports new completed QM/Crew work with verification passing, intended changes committed locally, and the deck clean, **Captain** offers the human appropriate outbound next steps such as pushing the branch, opening a PR, tagging/releasing, publishing, or deploying. Captain performs outbound actions only with explicit human approval and project permission.
12. If QM, Crew, or Bosun finds a missing/contradictory requirement, they stop and report a blocker.
13. When moving from **Quartermaster**, **Crew Mate**, or **Bosun** back to **Captain**, do **not** clear the concrete blocker context unless there is a separate reason to. Captain then turns that context into durable specs/assets and the loop resumes.

No new Captain voyage from a dirty deck. Bosun owns local repo hygiene and local commit custody, but does not push, tag, publish, or release. Outbound push/publish/deploy/release actions are Captain/human decisions after a clean Bosun report.

## Short Demo Narrative

1. Captain writes `.feature`, `HANDOVER.md`, and any referenced `assets/**`.
2. Clear/reset context.
3. Quartermaster reads only repo artifacts and creates failing verification.
4. Clear/reset context if needed, so Crew does not inherit product decisions from chat.
5. Crew Mate reads failing verification and implements the smallest passing change.
6. Bosun removes stale leftovers, reruns checks, and commits locally.
7. Captain offers human-approved outbound next steps if the completed work should be pushed, published, released, or deployed.
8. Next Captain starts from a clean deck.

## Why BDD First?

BDD/Gherkin is Shipshape's first backend because:

- models already know it,
- humans can review it,
- it is language/framework neutral,
- tooling exists for almost every stack,
- it separates intent from implementation,
- QM gets something concrete to turn into tests.

BDD is the first backend, not the identity. Future backends could include design cards, OpenAPI, JSON Schema, statecharts, approval tests, property specs, TLA+, Alloy, Lean, Coq, Dafny, or other durable specification formats.

## Durable `assets/`

Shipshape treats a project-root `assets/` directory as durable human/Captain-authored source material, not generated implementation output.

Use `assets/` for things specs depend on but agents should not casually rewrite, such as:

- approved copy or content,
- brand files and design references,
- images, mockups, diagrams, or screenshots,
- reference data,
- fixture-like examples explicitly approved as source material.

Captain may create or update `assets/**` while clarifying product intent with the human. Quartermaster and Crew Mate may read `assets/**`, but must treat it as read-only: QM can derive tests from assets, and Crew can implement behavior that consumes them. Bosun may remove stale assets only when durable specs have retired them.

This keeps durable authored material separate from generated tests, fixtures, harnesses, and implementation code. See `templates/assets-policy.md` for a reusable project policy.

## Repository Layout

```text
shipshape/
├── shipshape/SKILL.md          # orientation/router skill: /shipshape
├── captain/SKILL.md            # role skill: /captain
├── qm/SKILL.md                 # role skill: /qm
├── crew/SKILL.md               # role skill: /crew
├── bosun/SKILL.md              # role skill: /bosun
├── README.md
├── agents/                     # portable role charters
├── adapters/
├── templates/
└── docs/
```

## Distribution channels

Shipshape is stack-agnostic. It is not an npm-first dependency model, and projects do not need JavaScript tooling to adopt it.

For most agent runtimes, install all Shipshape skills with the open skills CLI:

```bash
npx skills add dmytri/shipshape --skill '*'
```

Install globally:

```bash
npx skills add dmytri/shipshape --global --skill '*'
```

Install for every skills.sh-supported agent in the project:

```bash
npx skills add dmytri/shipshape --agent '*' --skill '*'
```

Install for a specific supported agent:

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

See `adapters/README.md` for the canonical support matrix, verified project-local install paths, and runtime-specific notes.

Notes:

- `nanobot` is not currently a valid `skills` CLI agent alias; use the manual fallback in `adapters/nanobot.md`.
- Plain `aider` is not currently a valid alias; use `aider-desk` for AiderDesk.

Preview/use without installing:

```bash
npx skills use dmytri/shipshape --skill captain
```

List the skills discovered by the CLI:

```bash
npx skills add dmytri/shipshape --list
```

The public skills.sh page is:

```text
https://skills.sh/dmytri/shipshape
```

For Pi, install the Pi-specific package:

```bash
pi install npm:pi-shipshape
```

`pi-shipshape` exists to distribute the Pi extension and bundled Shipshape prompts through Pi's npm-based package system. Do not add `pi-shipshape` as a normal project dependency unless you specifically need Pi packaging behavior.

The open skills install exposes `/shipshape` as an orientation/router skill and the role skills `/captain`, `/qm`, `/crew`, and `/bosun` when installed with `--skill '*'`.

The Pi package installs the bundled Shipshape prompts and Pi extension, which provides:

- `/captain [topic]`
- `/qm [optional focus]`
- `/crew <failing target>`
- `/bosun [completed target or change summary]`
- `/clearrole`

After installing or updating, run `/reload` in Pi if needed.

skills.sh discovers public GitHub skill repositories after they are seen by the `skills` CLI. If the page or badge has not appeared yet, run a normal install once and allow time for the skills.sh cache to refresh.

## Quick Adoption

1. Install with `npx skills add dmytri/shipshape --skill '*'` or copy `templates/AGENTS.md` into your project and fill in the placeholders.
2. Copy `templates/HANDOVER.md` if you want a durable current-state handoff.
3. Use the role skills in `captain/`, `qm/`, `crew/`, and `bosun/`; for runtimes without multi-skill support, copy role prompts from `agents/` into your agent runtime.
4. Configure your project-specific commands:
   - `<test command>`
   - `<focused test command>`
   - `<typecheck command>`
   - `<spec directory>`
   - `<implementation directory>`
5. Start with the Captain.
6. If Captain finds the deck unready, run Bosun first and return to Captain after Bosun leaves a clean deck.
7. Before invoking Quartermaster after Captain, clear the session or start a fresh agent so QM only sees durable repo artifacts. QM is instructed to refuse if it detects Captain/human discovery context.
8. After Crew Mate makes verification pass, run Bosun to clean the repo and commit locally before the next Captain run.
9. If Quartermaster, Crew Mate, or Bosun reports a blocker, start Captain from that blocker context instead of clearing. Captain can use the concrete evidence to update durable specs/assets; after Captain resolves it, clear again before returning to QM.

See `docs/adoption-guide.md` for details, `docs/golden-path.md` for an end-to-end example, and `docs/adoption-checklist.md` for readiness checks.

## Shipshape Compatibility Checklist

A workflow is Shipshape-compatible if:

- product intent is written to durable repo artifacts,
- verification is produced from artifacts, not chat,
- implementation starts from failing verification,
- role context is reset or isolated between handoffs,
- stale artifacts are cleaned before the next Captain run,
- local commit custody is separated from push/publish/release actions.

## How Shipshape Relates to Other Spec Tools

OpenSpec, Spec Kit, and similar tools are useful for structuring spec and planning context. Shipshape solves a different failure mode: unsafe agent handoffs.

OpenSpec / Spec Kit structure context. Shipshape destroys context between roles.

Agent orchestration tools decide where and how agents run. Shipshape defines how agents hand off work safely.

## Operational docs

- `docs/golden-path.md` — smallest complete Captain → QM → Crew → Bosun example.
- `docs/adoption-guide.md` — how to add Shipshape to a project.
- `docs/adoption-checklist.md` — readiness checklist for projects adopting Shipshape.
- `docs/context-firewall.md` — Quartermaster fresh-context refusal and pass behavior.
- `templates/blocker-report.md` — standard format for QM/Crew/Bosun blockers.

## Portability

Shipshape does not require a specific language, package manager, test runner, or agent vendor.

It assumes only that an agent can:

- read project files,
- write project files,
- run or request verification commands,
- preserve durable instructions in the repository.

See `docs/portability-contract.md` and `adapters/README.md` for runtime-specific install paths.

## Origin

Shipshape was extracted from work done at [Saleor](https://saleor.io) — an open-source, headless GraphQL e-commerce platform

If you're building an e-commerce project, Saleor is worth a serious look: modern GraphQL API, a great dashboard, and a strong open-source community.

For an agent-friendly way to spin up Saleor storefront work, see [Jolly](https://jolly.cool) (still experimental, so consider it a preview).

# Shipshape

[![skills.sh](https://skills.sh/b/dmytri/shipshape)](https://skills.sh/dmytri/shipshape)

Shipshape is a portable three-role, spec-driven workflow for coding agents.

**Specs are durable. Code is disposable. Agents are replaceable.**

Install Shipshape, start with the Captain, then run Quartermaster and Crew from fresh/role-appropriate agent sessions:

```bash
npx skills add dmytri/shipshape
```

```text
/captain describe the feature or change
# Captain writes durable specs/instructions and updates assets/ when needed.

/qm optional focused area
# Quartermaster reads repository artifacts only and writes failing tests.

/crew failing test or target
# Crew Mate implements the smallest production change needed to pass.
```

For Pi:

```bash
pi install npm:@dk/shipshape
```

```text
/captain describe the feature or change
/qm optional focused area
/crew failing test or target
```

It is extracted from a real repository workflow and generalized so it can be used with Zed, Claude, Cursor, OpenCode, Hermes, Pi, or any agent runner that can read repository files and edit code.

## The Idea

Most agent failures come from hidden context:

- decisions buried in chat,
- stale tests after spec changes,
- implementation agents guessing product behavior,
- handoffs that only exist in one session.

Shipshape fixes that by making repository artifacts the source of truth.

```text
Human ↔ Captain → specs/instructions + assets/ → Quartermaster → tests → Crew Mate → code
```

## Roles

| Role | Talks to humans? | Writes specs? | Writes tests? | Writes implementation? |
|---|---:|---:|---:|---:|
| Captain | Yes | Yes | No | No |
| Quartermaster | No | No | Yes | Normally no |
| Crew Mate | No | No | No | Yes |

## Core Workflow

1. **Captain** collaborates with the human and updates durable specs/instructions.
2. Captain may create/edit durable human-authored assets under root `assets/` when specs reference content, brand files, images, mockups, reference data, or approved fixture-like examples.
3. Captain ensures the target project's `README.md` and `AGENTS.md` declare that the repo is built with Shipshape and link to `https://github.com/dmytri/shipshape`.
4. Captain deletes generated/derived artifacts that may have been invalidated by spec changes, but does not delete `assets/**` unless explicitly instructed or specs retire the asset.
5. The user clears the Captain session or starts a new agent session, then starts the **Quartermaster**. QM must not inherit Captain chat context; if it detects that context, it refuses to continue.
6. Quartermaster writes missing tests, QM-owned fixtures, step definitions, and harnesses; `assets/**` is read-only.
7. Failing tests are assigned to **Crew Mates**.
8. Crew Mates implement the smallest production change needed to pass one target; `assets/**` is read-only.
9. If QM or Crew finds a missing/contradictory requirement, they stop and report a blocker.
10. Captain resolves the blocker by updating specs, then the loop resumes.

## Repository Layout

```text
shipshape/
├── SKILL.md
├── README.md
├── agents/
├── commands/
├── adapters/
├── templates/
└── docs/
```

## Install with Pi

Install Shipshape in Pi:

```bash
pi install npm:@dk/shipshape
```

This installs the Shipshape skill and Pi extension, which provides:

- `/captain [topic]`
- `/qm [optional focus]`
- `/crew <failing target>`
- `/clearrole`

After installing or updating, run `/reload` in Pi if needed.


## Install with skills.sh

Install with the open skills CLI:

```bash
npx skills add dmytri/shipshape
```

Install globally:

```bash
npx skills add dmytri/shipshape --global
```

Install for a specific supported agent:

```bash
npx skills add dmytri/shipshape --agent cursor
npx skills add dmytri/shipshape --agent claude-code
npx skills add dmytri/shipshape --agent zed
```

Preview/use without installing:

```bash
npx skills use dmytri/shipshape
```

List the skill discovered by the CLI:

```bash
npx skills add dmytri/shipshape --list
```

The public skills.sh page is:

```text
https://skills.sh/dmytri/shipshape
```

skills.sh discovers public GitHub skill repositories after they are seen by the `skills` CLI. If the page or badge has not appeared yet, run a normal install once and allow time for the skills.sh cache to refresh.

## Quick Adoption

1. Install with `npx skills add dmytri/shipshape` or copy `templates/AGENTS.md` into your project and fill in the placeholders.
2. Copy `templates/HANDOVER.md` if you want a durable current-state handoff.
3. Copy role prompts from `agents/` or command entrypoints from `commands/` into your agent runtime.
4. Configure your project-specific commands:
   - `<test command>`
   - `<focused test command>`
   - `<typecheck command>`
   - `<spec directory>`
   - `<implementation directory>`
5. Start with the Captain.
6. Before invoking Quartermaster, clear the session or start a fresh agent so QM only sees committed artifacts. QM is instructed to refuse if it detects Captain/human discovery context.

See `docs/adoption-guide.md` for details.

## Portability

Shipshape does not require a specific language, package manager, test runner, or agent vendor.

It assumes only that an agent can:

- read project files,
- write project files,
- run or request verification commands,
- preserve durable instructions in the repository.

See `docs/portability-contract.md`.

# Shipshape

[![skills.sh](https://skills.sh/b/dmytri/shipshape)](https://skills.sh/dmytri/shipshape)

Shipshape is a portable three-role, spec-driven workflow for coding agents.

It is extracted from a real repository workflow and generalized so it can be used with Zed, Claude, Cursor, OpenCode, Hermes, Pi, or any agent runner that can read repository files and edit code.

## The Idea

Most agent failures come from hidden context:

- decisions buried in chat,
- stale tests after spec changes,
- implementation agents guessing product behavior,
- handoffs that only exist in one session.

Shipshape fixes that by making repository artifacts the source of truth.

```text
Human ↔ Captain → specs/instructions → Quartermaster → tests → Crew Mate → code
```

## Roles

| Role | Talks to humans? | Writes specs? | Writes tests? | Writes implementation? |
|---|---:|---:|---:|---:|
| Captain | Yes | Yes | No | No |
| Quartermaster | No | No | Yes | Normally no |
| Crew Mate | No | No | No | Yes |

## Core Workflow

1. **Captain** collaborates with the human and updates durable specs/instructions.
2. Captain deletes artifacts that may have been invalidated by spec changes.
3. The user clears the Captain session or starts a new agent session, then starts the **Quartermaster**. QM must not inherit Captain chat context; if it detects that context, it refuses to continue.
4. Quartermaster writes missing tests, fixtures, step definitions, and harnesses.
5. Failing tests are assigned to **Crew Mates**.
6. Crew Mates implement the smallest production change needed to pass one target.
7. If QM or Crew finds a missing/contradictory requirement, they stop and report a blocker.
8. Captain resolves the blocker by updating specs, then the loop resumes.

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

Shipshape is packaged for Pi as `@dk/shipshape`.

```bash
pi install npm:@dk/shipshape
```

This installs the Shipshape skill and the optional Pi extension that provides:

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

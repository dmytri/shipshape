# Shipshape

Shipshape is a portable three-role, spec-driven workflow for coding agents.

It is extracted from a real repository workflow and generalized so it can be used with Zed, Claude, OpenCode, Hermes, Pi, or any agent runner that can read repository files and edit code.

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
3. The user clears the Captain session or starts a new agent session, then starts the **Quartermaster**. QM must not inherit Captain chat context.
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

## Quick Adoption

1. Copy `templates/AGENTS.md` into your project and fill in the placeholders.
2. Copy `templates/HANDOVER.md` if you want a durable current-state handoff.
3. Copy role prompts from `agents/` or command entrypoints from `commands/` into your agent runtime.
4. Configure your project-specific commands:
   - `<test command>`
   - `<focused test command>`
   - `<typecheck command>`
   - `<spec directory>`
   - `<implementation directory>`
5. Start with the Captain.
6. Before invoking Quartermaster, clear the session or start a fresh agent so QM only sees committed artifacts.

See `docs/adoption-guide.md` for details.

## Portability

Shipshape does not require a specific language, package manager, test runner, or agent vendor.

It assumes only that an agent can:

- read project files,
- write project files,
- run or request verification commands,
- preserve durable instructions in the repository.

See `docs/portability-contract.md`.

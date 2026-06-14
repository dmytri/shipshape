# Shipshape Agent Adapters

Shipshape installs as five sibling skills:

```text
shipshape/SKILL.md  # workflow orientation/router
captain/SKILL.md    # human-facing discovery and durable specs
qm/SKILL.md         # fresh-context verification and tests
crew/SKILL.md       # focused implementation for one failing target
bosun/SKILL.md      # repo hygiene and local commit custody
```

For most users, install all Shipshape skills with:

```bash
npx skills add dmytri/shipshape --skill '*'
```

To install for every `skills` CLI-supported agent in a project:

```bash
npx skills add dmytri/shipshape --agent '*' --skill '*'
```

No `--full-depth` flag is required. Shipshape is intentionally laid out as sibling skill directories so normal `skills` CLI discovery finds each skill.

## Supported agent aliases and project-local paths

These aliases and paths reflect verified `skills` CLI behavior.

| Agent | `--agent` alias | Project-local install path | Adapter notes |
|---|---|---|---|
| Claude Code | `claude-code` | `.claude/skills/` | [`claude.md`](claude.md) |
| Zed | `zed` | `.agents/skills/` | [`zed.md`](zed.md) |
| Cursor | `cursor` | `.agents/skills/` | [`cursor.md`](cursor.md) |
| OpenCode | `opencode` | `.agents/skills/` | [`opencode.md`](opencode.md) |
| Codex | `codex` | `.agents/skills/` | [`codex.md`](codex.md) |
| GitHub Copilot | `github-copilot` | `.agents/skills/` | [`github-copilot.md`](github-copilot.md) |
| OpenClaw | `openclaw` | `skills/` | [`openclaw.md`](openclaw.md) |
| Goose | `goose` | `.goose/skills/` | [`goose.md`](goose.md) |
| Hermes Agent | `hermes-agent` | `.hermes/skills/` | [`hermes.md`](hermes.md) |
| AiderDesk | `aider-desk` | `.aider-desk/skills/` | [`aider-desk.md`](aider-desk.md) |

Expected installed entries under each project-local path:

```text
<skills-path>/shipshape/SKILL.md
<skills-path>/captain/SKILL.md
<skills-path>/qm/SKILL.md
<skills-path>/crew/SKILL.md
<skills-path>/bosun/SKILL.md
```

## Invalid or unsupported aliases

| Name | Status | What to do |
|---|---|---|
| Nanobot | Not a valid `skills` CLI alias | Use [`nanobot.md`](nanobot.md) or [`generic.md`](generic.md) manual fallback. |
| Aider / `aider` | Not a valid `skills` CLI alias | Use `aider-desk` for AiderDesk, or [`generic.md`](generic.md) for other Aider setups. |

## Role usage is the same across agents

- Use `shipshape` for workflow orientation.
- Use `captain` for human-facing discovery, specs, blockers, and durable project instructions.
- Before switching from Captain to Quartermaster, clear the conversation or start a fresh agent session.
- Use `qm` only from fresh/cleared context for verification, tests, harnesses, and coverage.
- Use `crew` for one failing implementation target at a time.
- Use `bosun` after Crew passes to clean the repo, rerun checks, and commit locally.
- If QM, Crew, or Bosun finds a missing or contradictory requirement, stop and escalate back to Captain with the concrete blocker context.
- Bosun must not push, tag, publish, release, change product intent, add scenarios/tests, or implement new behavior.

## Manual fallback

If an agent does not consume installed skills directly, use [`generic.md`](generic.md): keep `AGENTS.md` in the project, keep the portable role prompts from `agents/` available, and invoke the matching role prompt manually.

## Pi

Pi uses its own package path and extension mechanism. Install with:

```bash
pi install npm:pi-shipshape
```

See [`pi.md`](pi.md) for Pi-specific commands and extension behavior.

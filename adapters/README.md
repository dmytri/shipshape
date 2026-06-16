# Shipshape Runtime Support

Install all Shipshape skills with the `skills` CLI:

```bash
npx skills add dmytri/shipshape --skill '*'
```

To install for every supported agent in a project:

```bash
npx skills add dmytri/shipshape --agent '*' --skill '*'
```

For a specific agent, use the alias from the table below.

## Supported agents

| Agent | `--agent` alias | Skills install path | Notes |
|---|---|---|---|
| Claude Code | `claude-code` | `.claude/skills/` | |
| Zed | `zed` | `.agents/skills/` | |
| Cursor | `cursor` | `.agents/skills/` | Optionally add `.cursor/rules/shipshape.md` with a workflow reminder |
| OpenCode | `opencode` | `.agents/skills/` | |
| Codex | `codex` | `.agents/skills/` | |
| GitHub Copilot | `github-copilot` | `.agents/skills/` | |
| OpenClaw | `openclaw` | `skills/` | Skills run with full agent permissions; review before use |
| Goose | `goose` | `.goose/skills/` | |
| Hermes Agent | `hermes-agent` | `.hermes/skills/` | |
| AiderDesk | `aider-desk` | `.aider-desk/skills/` | |

Installed skill directories under each path:

```text
<skills-path>/shipshape/SKILL.md
<skills-path>/captain/SKILL.md
<skills-path>/qm/SKILL.md
<skills-path>/crew/SKILL.md
<skills-path>/bosun/SKILL.md
```

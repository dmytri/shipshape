# Nanobot Adapter

Nanobot is not currently a valid `skills` CLI `--agent` alias.

Verified invalid command:

```bash
npx skills add dmytri/shipshape --agent nanobot --skill '*'
```

The CLI rejects `nanobot` and lists supported aliases such as `codex`, `github-copilot`, `openclaw`, `goose`, `hermes-agent`, `opencode`, `cursor`, `claude-code`, and `zed`.

## Manual Fallback

Until Nanobot is added to the `skills` CLI, use Shipshape as portable repository instructions:

1. Add `templates/AGENTS.md` to the project root and fill in placeholders.
2. Keep role prompts from `agents/` available to Nanobot.
3. Start Nanobot with the matching role prompt:
   - `agents/captain.md` for human-facing spec work.
   - `agents/quartermaster.md` only in a fresh/cleared context for verification.
   - `agents/crew-mate.md` for one failing implementation target.

If Nanobot supports a custom skills directory, copy the four sibling skill directories manually:

```text
shipshape/SKILL.md
captain/SKILL.md
qm/SKILL.md
crew/SKILL.md
```

Use the same role boundaries and context firewall documented in `docs/workflow.md`.

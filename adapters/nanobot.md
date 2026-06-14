# Nanobot Adapter

Nanobot is not currently a valid `skills` CLI `--agent` alias.

Verified invalid command:

```bash
npx skills add dmytri/shipshape --agent nanobot --skill '*'
```

The CLI rejects `nanobot` and lists supported aliases such as `codex`, `github-copilot`, `openclaw`, `goose`, `hermes-agent`, `opencode`, `cursor`, `claude-code`, and `zed`.

See [`README.md`](README.md) for the supported alias matrix.

## Manual fallback

Until Nanobot is added to the `skills` CLI, use Shipshape as portable repository instructions. The general fallback is documented in [`generic.md`](generic.md).

Minimal Nanobot setup:

1. Add `templates/AGENTS.md` to the project root and fill in placeholders.
2. Keep role prompts from `agents/` available to Nanobot.
3. Start Nanobot with the matching role prompt:
   - `agents/captain.md` for human-facing spec work.
   - `agents/quartermaster.md` only in a fresh/cleared context for verification.
   - `agents/crew-mate.md` for one failing implementation target.
   - `agents/bosun.md` for repo hygiene and local commit custody after Crew passes.

If Nanobot supports a custom skills directory, copy the sibling skill directories manually:

```text
shipshape/SKILL.md
captain/SKILL.md
qm/SKILL.md
crew/SKILL.md
bosun/SKILL.md
```

Use the same role boundaries and context firewall documented in `docs/workflow.md`.

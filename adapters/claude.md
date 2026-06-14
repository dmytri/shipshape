# Claude Code Adapter

Claude Code is supported by the `skills` CLI using the `claude-code` alias.

```bash
npx skills add dmytri/shipshape --agent claude-code --skill '*'
```

Project-local installs go under `.claude/skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

Expected Claude skill entrypoints when installed with `--skill '*'`:

- `/shipshape` — workflow orientation and role router.
- `/captain <topic>` — discovery/spec updates and blocker resolution.
- `/qm <optional focus>` — fresh-context verification work.
- `/crew <failing target>` — focused implementation.
- `/bosun <completed target>` — repo hygiene and local commit custody.

## Project files

A Shipshape target project should still contain durable workflow files:

```text
<project>/AGENTS.md
<project>/HANDOVER.md        # optional
<project>/<spec directory>/  # Gherkin .feature files
<project>/assets/            # optional Captain/human-authored source material
```

Copy `templates/AGENTS.md` to `<project>/AGENTS.md` and configure placeholders. Copy `templates/HANDOVER.md` if useful.

## Skills-first support

Shipshape targets current Claude Code skill installs. If role skills are unavailable, update the skills install rather than using command-file fallbacks.

If your Claude setup does not expose the role skills, install or update with the `skills` CLI command above and verify the sibling skill directories exist under `.claude/skills/`.

If the runtime supports subagents, use `agents/crew-mate.md` and `agents/bosun.md` as role-specialized subagent definitions. If subagents are unavailable, document that in `HANDOVER.md`. Quartermaster may use the Crew fallback only when documented, and must assume Bosun role if no Bosun subagent is available.

## Quartermaster context firewall

When moving from Captain to Quartermaster, clear the Captain session or start a new Claude session before invoking `/qm`. Quartermaster must use only durable specs, source-controlled tests, instructions, and explicit handoff files in the repository.

Claude prompts cannot reliably prevent a user from typing `/qm` in the wrong chat, so enforcement is prompt-level: `qm/SKILL.md` instructs QM to inspect visible conversation context first and refuse if Captain/human discovery context is present.

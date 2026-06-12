# Claude Adapter

Claude Code can use Shipshape as first-class skills. The preferred Claude layout is multiple sibling skills: `/shipshape` explains the workflow while `/captain`, `/qm`, and `/crew` are the working role entrypoints.

## Preferred skills.sh install

```bash
npx skills add dmytri/shipshape --agent claude-code --skill '*'
```

Expected Claude skill entrypoints when installed with `--skill '*'`:

- `/shipshape` — workflow orientation and role router.
- `/captain <topic>` — discovery/spec updates and blocker resolution.
- `/qm <optional focus>` — fresh-context verification work.
- `/crew <failing target>` — focused implementation.

The role skills live in this repository at:

```text
captain/SKILL.md
qm/SKILL.md
crew/SKILL.md
```

## Project files

A Shipshape target project should still contain durable workflow files:

```text
<project>/AGENTS.md
<project>/HANDOVER.md        # optional
<project>/<spec directory>/  # Gherkin .feature files
<project>/assets/            # optional Captain/human-authored source material
```

Copy `templates/AGENTS.md` to `<project>/AGENTS.md` and configure placeholders. Copy `templates/HANDOVER.md` if useful.

## Legacy command fallback

If a Claude setup does not expose the multiple skills as `/captain`, `/qm`, and `/crew`, use the legacy command files:

```text
<project>/.claude/commands/captain.md
<project>/.claude/commands/qm.md
<project>/.claude/commands/crew.md
<project>/.claude/agents/crew-mate.md   # optional subagent definition
```

Copy command files from `commands/` into `.claude/commands/`, and copy `agents/crew-mate.md` into `.claude/agents/crew-mate.md` if the runtime supports subagents.

## Quartermaster context firewall

When moving from Captain to Quartermaster, clear the Captain session or start a new Claude session before invoking `/qm`. Quartermaster must use only committed specs, tests, instructions, and explicit durable handoff files.

Claude prompts cannot reliably prevent a user from typing `/qm` in the wrong chat, so enforcement is prompt-level: `qm/SKILL.md` and `commands/qm.md` instruct QM to inspect visible conversation context first and refuse if Captain/human discovery context is present.

If subagents are unavailable, document that in `HANDOVER.md` and let the Quartermaster use the fallback rule.

# Claude Adapter

Claude-style agents can use Shipshape as repository instructions, slash commands, and optional subagents.

## Suggested Layout

```text
<project>/AGENTS.md
<project>/HANDOVER.md
<project>/.claude/commands/captain.md
<project>/.claude/commands/qm.md
<project>/.claude/commands/crew.md
<project>/.claude/agents/crew-mate.md
```

## Installation Pattern

1. Copy `templates/AGENTS.md` to `<project>/AGENTS.md` and configure placeholders.
2. Copy `templates/HANDOVER.md` to `<project>/HANDOVER.md` if useful.
3. Copy command files from `commands/` into `.claude/commands/`.
4. Copy `agents/crew-mate.md` into `.claude/agents/crew-mate.md` if the runtime supports subagents.

## Usage

- `/captain <topic>` for discovery/spec updates.
- Start a new/cleared session, then `/qm <optional focus>` for verification work. Do not run `/qm` in the Captain conversation. The QM command prompt includes a context-firewall refusal if it detects Captain/human discovery context.
- `/crew <failing target>` for manual Crew Mate implementation.

## Quartermaster Context Firewall

Claude command prompts cannot reliably prevent a user from typing `/qm` in the wrong chat, so enforcement is prompt-level: `.claude/commands/qm.md` instructs QM to inspect visible conversation context first and refuse if Captain/human discovery context is present.

If subagents are unavailable, document that in `HANDOVER.md` and let the Quartermaster use the fallback rule.

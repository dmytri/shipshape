# OpenCode Adapter

Exact OpenCode integration details may vary by version and configuration. Shipshape does not require OpenCode-specific APIs.

## Preferred skills.sh install

Install all Shipshape skills with the `opencode` alias:

```bash
npx skills add dmytri/shipshape --agent opencode --skill '*'
```

This provides sibling skills:

```text
.agents/skills/shipshape/SKILL.md
.agents/skills/captain/SKILL.md
.agents/skills/qm/SKILL.md
.agents/skills/crew/SKILL.md
```

Global install uses `~/.config/opencode/skills/`:

```bash
npx skills add dmytri/shipshape --agent opencode --global --skill '*'
```

Use `shipshape` for workflow orientation, `captain` for specs, `qm` for verification, and `crew` for focused implementation.

## Generic Pattern

If OpenCode does not consume skills directly, use Shipshape as plain repository instructions:

1. Add `AGENTS.md` from `templates/AGENTS.md` to the project root.
2. Fill in command and directory placeholders.
3. Keep role prompts from `agents/` accessible in the repository.
4. Start sessions by pasting or referencing the desired role prompt:
   - Captain for human-facing specification work.
   - Quartermaster for tests/harness/verification, only after clearing Captain context or starting a fresh session. The Quartermaster prompt must refuse if it detects Captain/human discovery context.
   - Crew Mate for one failing implementation target.

## If OpenCode Supports Commands

Map command entrypoints from `commands/` to OpenCode's command mechanism.

## If OpenCode Supports Subagents

Register `agents/crew-mate.md` as the implementation subagent. The Quartermaster should dispatch one failing target at a time.

## If Not

Run Crew Mate sessions manually, or allow the Quartermaster fallback after it has written failing tests and the fallback is documented in `HANDOVER.md`.

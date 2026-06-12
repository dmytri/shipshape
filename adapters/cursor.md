# Cursor Adapter

Cursor can use Shipshape as repository instructions plus reusable skills/role prompts. Exact Cursor features vary by version and workspace configuration, so this adapter keeps a skills-first path with manual fallbacks.

## Preferred skills.sh install

```bash
npx skills add dmytri/shipshape --agent cursor --skill '*'
```

Expected project-local skill layout from the skills CLI:

```text
<project>/.agents/skills/shipshape/SKILL.md
<project>/.agents/skills/captain/SKILL.md
<project>/.agents/skills/qm/SKILL.md
<project>/.agents/skills/crew/SKILL.md
```

Use the installed skills by name if your Cursor setup exposes skills to the agent. Otherwise, keep the role prompts available and reference them manually.

## Recommended Project Files

```text
<project>/AGENTS.md
<project>/HANDOVER.md                         # optional
<project>/.cursor/rules/shipshape.md          # optional, if your Cursor setup uses rules
<project>/.agents/skills/*/SKILL.md           # preferred skills install
<project>/shipshape/agents/*.md               # optional manual fallback prompts
```

## Minimal Setup

1. Install all Shipshape skills with `npx skills add dmytri/shipshape --agent cursor --skill '*'`.
2. Copy `templates/AGENTS.md` to `<project>/AGENTS.md` and fill in the placeholders.
3. Copy `templates/HANDOVER.md` if you want durable current-state handoff.
4. If your Cursor setup uses project rules, add a rule that points agents to `AGENTS.md` and the Shipshape role skills.

## Using Roles in Cursor

### Captain

Use the `captain` skill or `agents/captain.md` fallback prompt.

Use this for:

- human-facing discovery,
- writing or updating specs,
- resolving blockers,
- updating `AGENTS.md` or durable project instructions.

### Quartermaster

Before starting Quartermaster, clear the Captain chat or open a new Cursor chat/session.

This is mandatory: the Quartermaster must not inherit Captain/human discovery context. It should read only committed specs, tests, instructions, and explicit durable handoff files.

Use the `qm` skill or `agents/quartermaster.md` fallback prompt. The QM prompt includes a context-firewall refusal. If it can see Captain/human discovery context, it must stop and ask you to start a fresh/cleared chat.

### Crew Mate

Use the `crew` skill or `agents/crew-mate.md` fallback prompt for one failing verification target.

Good target:

```text
Make <focused failing test/scenario> pass. Read committed specs and tests for behavior.
```

Avoid broad prompts such as:

```text
Implement the whole feature.
```

## Rules File Pattern

If you keep a Cursor rules file, use language like:

```md
This project uses Shipshape.
Read AGENTS.md before substantive work.
Use the captain skill for human-facing spec work.
Use the qm skill only in a fresh/cleared chat after Captain. If Quartermaster detects Captain/human discovery context, it must refuse to continue.
Use the crew skill for one failing test/scenario at a time.
Do not rely on prior chat for product requirements.
```

## No Subagent Dispatch

If Cursor cannot dispatch separate Crew Mate agents in your setup, run Crew Mate chats manually. If manual Crew sessions are impractical, document Quartermaster fallback in `HANDOVER.md` before allowing QM to implement after writing failing tests.

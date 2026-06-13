# Cursor Adapter

Cursor is supported by the `skills` CLI using the `cursor` alias.

```bash
npx skills add dmytri/shipshape --agent cursor --skill '*'
```

Project-local installs go under `.agents/skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

Cursor features vary by version and workspace configuration. If your Cursor setup exposes installed skills, use `shipshape`, `captain`, `qm`, and `crew` by name. Otherwise use [`generic.md`](generic.md) with the portable prompts in `agents/`.

## Recommended project files

```text
<project>/AGENTS.md
<project>/HANDOVER.md                         # optional
<project>/.cursor/rules/shipshape.md          # optional, if your Cursor setup uses rules
<project>/.agents/skills/*/SKILL.md           # preferred skills install
```

## Optional rules file pattern

If you keep a Cursor rules file, use language like:

```md
This project uses Shipshape.
Read AGENTS.md before substantive work.
Use the captain skill for human-facing spec work.
Use the qm skill only in a fresh/cleared chat after Captain. If Quartermaster detects Captain/human discovery context, it must refuse to continue.
Use the crew skill for one failing test/scenario at a time.
Do not rely on prior chat for product requirements.
```

If Cursor cannot dispatch separate Crew Mate agents in your setup, run Crew Mate chats manually. If manual Crew sessions are impractical, document Quartermaster fallback in `HANDOVER.md` before allowing QM to implement after writing failing tests.

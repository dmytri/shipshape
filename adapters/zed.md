# Zed Adapter

Zed is supported by the `skills` CLI using the `zed` alias.

```bash
npx skills add dmytri/shipshape --agent zed --skill '*'
```

Project-local installs go under `.agents/skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

## Usage in Zed

Zed does not need Claude-style `.claude/commands` files. Use the skills by name in the Zed agent panel:

- Ask Zed to use the `shipshape` skill for workflow orientation.
- Ask Zed to use the `captain` skill for human-facing discovery, specs, and blocker resolution.
- Clear the conversation or start a fresh agent session, then ask Zed to use the `qm` skill for verification and test coverage.
- Ask Zed to use the `crew` skill for one failing implementation target.

If your Zed version exposes installed skills as slash entries, `/captain`, `/qm`, `/crew`, and `/shipshape` may appear. If it does not, invoke them by name in natural language; the installed skill files are still available to the agent.

## Project adoption

1. Copy `templates/AGENTS.md` to the project root.
2. Fill in project-specific placeholders for specs, tests, implementation directories, commands, handover, and assets.
3. Optionally copy `templates/HANDOVER.md`.
4. Start with the `captain` skill.
5. Before running Quartermaster, clear the session or start a fresh agent session so QM does not inherit Captain/human discovery chat context.

If Zed supports spawning or routing to specialized agents in your setup, Quartermaster can dispatch Crew Mate tasks. If not, run separate `crew` skill sessions manually, or document the Quartermaster fallback in `HANDOVER.md` before allowing QM to implement after writing failing tests.

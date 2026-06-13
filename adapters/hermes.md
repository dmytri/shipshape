# Hermes Agent Adapter

Hermes Agent is supported by the `skills` CLI using the `hermes-agent` alias.

```bash
npx skills add dmytri/shipshape --agent hermes-agent --skill '*'
```

Project-local installs go under `.hermes/skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

Shipshape does not rely on Hermes-specific APIs. If Hermes does not consume installed skills directly, use [`generic.md`](generic.md) and invoke the portable role prompts manually.

Role mapping:

- Human-facing planning session → `captain` skill or Captain prompt.
- Fresh/cleared test/harness/coverage session → `qm` skill or Quartermaster prompt.
- Focused implementation session → `crew` skill or Crew Mate prompt.

If Hermes supports spawning or routing to specialized agents, have Quartermaster dispatch Crew Mate tasks with one failing target each. Otherwise, run separate sessions manually or document that Quartermaster fallback is allowed.

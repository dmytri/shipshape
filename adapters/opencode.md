# OpenCode Adapter

OpenCode is supported by the `skills` CLI using the `opencode` alias.

```bash
npx skills add dmytri/shipshape --agent opencode --skill '*'
```

Project-local installs go under `.agents/skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

Exact OpenCode integration details may vary by version and configuration. Shipshape does not require OpenCode-specific APIs.

If OpenCode consumes installed skills directly, use `shipshape`, `captain`, `qm`, `crew`, and `bosun` by name. If it does not, use [`generic.md`](generic.md) and keep role prompts from `agents/` accessible in the repository.

If OpenCode supports subagents, register `agents/crew-mate.md` as the implementation subagent and `agents/bosun.md` as the hygiene/local commit subagent.

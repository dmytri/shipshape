# Goose Adapter

Goose is supported directly by the `skills` CLI using the `goose` alias.

```bash
npx skills add dmytri/shipshape --agent goose --skill '*'
```

Project-local installs go under `.goose/skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

Use the installed skills by name:

- `shipshape` for orientation.
- `captain` for discovery/specification.
- `qm` for fresh-context verification.
- `crew` for focused implementation.

If Goose does not expose skills as slash commands in your setup, invoke the skill by name in natural language.

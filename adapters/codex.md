# Codex Adapter

Codex is supported directly by the `skills` CLI.

```bash
npx skills add dmytri/shipshape --agent codex --skill '*'
```

Project-local installs go under `.agents/skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

Use the installed skills by name:

- `shipshape` for workflow orientation.
- `captain` for human-facing discovery and specs.
- `qm` only in a fresh/cleared session for verification and tests.
- `crew` for one failing implementation target.

Codex should follow the standard Shipshape context firewall: do not run Quartermaster in a session that contains Captain/human discovery chat.

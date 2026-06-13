# OpenClaw Adapter

OpenClaw is supported directly by the `skills` CLI using the `openclaw` alias.

```bash
npx skills add dmytri/shipshape --agent openclaw --skill '*'
```

Project-local installs go under `skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

Use the installed role skills by name:

- `shipshape` for workflow orientation.
- `captain` for human-facing discovery/specification.
- `qm` only in a fresh/cleared context for verification.
- `crew` for one failing implementation target.

OpenClaw skills run with full agent permissions, so review installed skill files before use.

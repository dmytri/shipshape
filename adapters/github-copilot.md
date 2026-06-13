# GitHub Copilot Adapter

GitHub Copilot agent skills are supported by the `skills` CLI using the `github-copilot` alias.

```bash
npx skills add dmytri/shipshape --agent github-copilot --skill '*'
```

Project-local installs go under `.agents/skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

Use the installed skills by name in Copilot agent workflows:

- `shipshape` for orientation.
- `captain` for human-facing spec work.
- `qm` for fresh-context verification.
- `crew` for one failing target.

If Copilot does not expose skill names as slash entries in your environment, reference the skill name explicitly in the prompt.

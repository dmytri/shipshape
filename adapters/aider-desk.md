# AiderDesk Adapter

AiderDesk is supported by the `skills` CLI using the `aider-desk` alias.

```bash
npx skills add dmytri/shipshape --agent aider-desk --skill '*'
```

Project-local installs go under `.aider-desk/skills/`. See [`README.md`](README.md) for the full support matrix and expected sibling skill layout.

> Note: `aider` is not currently a valid `skills` CLI agent alias. Use `aider-desk` for AiderDesk, or use [`generic.md`](generic.md) for other Aider setups.

Use the installed role skills by name where AiderDesk exposes skills. For non-AiderDesk Aider workflows, use `agents/captain.md`, `agents/quartermaster.md`, and `agents/crew-mate.md` as manual prompts.

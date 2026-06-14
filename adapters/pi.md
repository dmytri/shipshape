# Pi Adapter

Pi uses its own package and extension mechanism. Install Shipshape for Pi with:

```bash
pi install npm:pi-shipshape
```

Pi package installation includes the bundled Shipshape prompts, five Shipshape skill directories, and the Pi extension at `adapters/pi-extension.ts`. The extension registers `/captain`, `/qm`, `/crew`, `/bosun`, and `/clearrole` commands and injects the selected role instructions into the session prompt.

## Minimal setup

1. Add `AGENTS.md` from `templates/AGENTS.md` to the project.
2. Fill in the placeholders for commands and directories.
3. Start the correct role with `/captain`, `/qm`, `/crew`, or `/bosun`.

## Pi slash commands

When installed with `pi install npm:pi-shipshape`, the package exposes `adapters/pi-extension.ts` through its `package.json` `pi.extensions` field.

The extension resolves role skill prompts in this order:

1. Project-local overrides in `.agents/skills/<role>/SKILL.md` or `<role>/SKILL.md`
2. The packaged Shipshape `<role>/SKILL.md` bundled with the installed npm package

For optional manual project-local installation:

1. Copy `adapters/pi-extension.ts` to the target project as `.pi/extensions/shipshape-roles.ts`.
2. Optionally add project-local skill overrides in `.agents/skills/<role>/SKILL.md` or `<role>/SKILL.md`.
3. Run `/reload` in Pi.

The extension provides:

- `/captain [topic]`
- `/qm [optional focus]`
- `/crew <failing target>`
- `/bosun [completed target or change summary]`
- `/clearrole`

The `/qm` command includes a programmatic best-effort guard: if `/captain` was used earlier in the same Pi session, `/qm` refuses to start and tells the user to open a fresh session. The QM prompt also includes the general context-firewall refusal for cases the extension cannot detect.

## Recommended use

- Use Captain sessions for all human discussion and spec changes.
- Clear/start fresh before Quartermaster. Do not run Quartermaster in a Captain conversation.
- After QM starts clean, transition by loading the next role: QM loads Crew for one failing target, Crew loads QM after the target passes, QM loads Bosun after verification passes, and Bosun loads Captain after a clean local commit.
- If QM, Crew, or Bosun hits missing product intent, load Captain with the concrete blocker context; after Captain resolves it, clear again before QM.

## Notes

The Pi extension is intentionally generic. It avoids project-specific test runners and product names. Put project-specific commands in `AGENTS.md`, `HANDOVER.md`, and project-local skill overrides when needed.

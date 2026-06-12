# Pi Adapter

Shipshape is installable as a Pi package:

```bash
pi install npm:pi-shipshape
```

Pi package installation includes both the Shipshape skill and the Pi extension at `adapters/pi-extension.ts`. The extension registers `/captain`, `/qm`, `/crew`, and `/clearrole` commands and injects the selected role instructions into the session prompt.

Pi agent environments can also use Shipshape manually as plain text workflow instructions plus role prompts, without installing the package.

## Minimal Setup

1. Add `AGENTS.md` from `templates/AGENTS.md` to the project.
2. Fill in the placeholders for commands and directories.
3. Keep `agents/captain.md`, `agents/quartermaster.md`, and `agents/crew-mate.md` available.
4. Start the correct role by loading or pasting the matching role prompt.

## Pi Slash Commands

When installed with `pi install npm:pi-shipshape`, the package exposes `adapters/pi-extension.ts` through its `package.json` `pi.extensions` field.

The installed Pi extension resolves role prompts in this order:

1. Project-local overrides in `commands/*.md`, `.claude/commands/*.md`, or `.agents/commands/*.md`
2. The packaged Shipshape prompts bundled with the installed npm package

For `/crew`, it resolves the Crew Mate definition in this order:

1. Project-local overrides in `agents/crew-mate.md`, `.claude/agents/crew-mate.md`, or `.agents/crew-mate.md`
2. The packaged Shipshape `agents/crew-mate.md` bundled with the installed npm package

So `pi install npm:pi-shipshape` works out of the box, while still allowing project-local overrides when a project needs them.

For optional manual project-local installation:

1. Copy `adapters/pi-extension.ts` to the target project as `.pi/extensions/shipshape-roles.ts`.
2. Optionally add project-local overrides in `commands/*.md` / `agents/crew-mate.md` (or the `.claude` / `.agents` equivalents).
3. Run `/reload` in Pi.

The extension provides:

- `/captain [topic]`
- `/qm [optional focus]`
- `/crew <failing target>`
- `/clearrole`

The `/qm` command includes a programmatic best-effort guard: if `/captain` was used earlier in the same Pi session, `/qm` refuses to start and tells the user to open a fresh session. The QM prompt also includes the general context-firewall refusal for cases the extension cannot detect.

## Recommended Use

- Use Captain sessions for all human discussion and spec changes.
- Use fresh/cleared Quartermaster sessions to generate and maintain tests. Do not run Quartermaster in a Captain conversation.
- Use Crew Mate sessions to make a single failing target pass.

## No Subagent Dispatch

If Pi cannot dispatch subagents, either run Crew Mates manually or allow the documented Quartermaster fallback.

## Notes

The Pi extension is intentionally generic. It avoids project-specific commands, test runners, and product names. Put project-specific commands in `AGENTS.md`, `HANDOVER.md`, and the role command prompts.

# Pi Adapter

Pi uses its own package and extension mechanism. Install Shipshape for Pi with:

```bash
pi install npm:pi-shipshape
```

Pi package installation includes the bundled Shipshape prompts, five Shipshape skill directories, and the Pi extension at `adapters/pi-extension.ts`. The extension registers `/captain`, `/qm`, `/crew`, `/bosun`, and `/clearrole` commands and injects the selected role instructions into the session prompt.

Pi agent environments can also use Shipshape manually as plain text workflow instructions plus role prompts, without installing the package. For non-Pi generic fallback guidance, see [`generic.md`](generic.md).

## Minimal setup

1. Add `AGENTS.md` from `templates/AGENTS.md` to the project.
2. Fill in the placeholders for commands and directories.
3. Prefer the installed role skills (`captain`, `qm`, `crew`, `bosun`) where available, or keep `agents/captain.md`, `agents/quartermaster.md`, `agents/crew-mate.md`, and `agents/bosun.md` available as manual fallback prompts.
4. Start the correct role with `/captain`, `/qm`, `/crew`, or `/bosun`, or by loading the matching fallback prompt.

## Pi slash commands

When installed with `pi install npm:pi-shipshape`, the package exposes `adapters/pi-extension.ts` through its `package.json` `pi.extensions` field.

The installed Pi extension resolves role skill prompts in this order:

1. Project-local skill overrides in `.agents/skills/<role>/SKILL.md` or `<role>/SKILL.md`
2. The packaged Shipshape `<role>/SKILL.md` bundled with the installed npm package

For `/crew` and `/bosun`, it resolves the matching agent definition in this order:

1. Project-local overrides in `agents/crew-mate.md` or `agents/bosun.md`, `.claude/agents/`, or `.agents/`
2. The packaged Shipshape agent prompt bundled with the installed npm package

So `pi install npm:pi-shipshape` works out of the box, while still allowing project-local overrides when a project needs them.

For optional manual project-local installation:

1. Copy `adapters/pi-extension.ts` to the target project as `.pi/extensions/shipshape-roles.ts`.
2. Optionally add project-local skill overrides in `.agents/skills/<role>/SKILL.md` or `<role>/SKILL.md`, and agent overrides in `agents/crew-mate.md` or `agents/bosun.md` (or the `.claude` / `.agents` equivalents for agent definitions).
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
- Use fresh/cleared Quartermaster sessions to generate and maintain tests. Do not run Quartermaster in a Captain conversation.
- Use Crew Mate sessions to make a single failing target pass.
- Use Bosun sessions after Crew passes to clean the repo and commit locally. Bosun must not push, tag, publish, or release.

If Pi cannot dispatch subagents, either run Crew Mates manually or allow the documented Quartermaster fallback. Bosun is not optional; if Pi cannot dispatch a Bosun subagent, Quartermaster should explicitly assume Bosun role and document that fallback.

## Notes

The Pi extension is intentionally generic. It avoids project-specific test runners and product names. Put project-specific commands in `AGENTS.md`, `HANDOVER.md`, and project-local skill overrides when needed.

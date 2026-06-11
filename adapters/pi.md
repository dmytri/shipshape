# Pi Adapter

Pi agent environments can use Shipshape as plain text workflow instructions plus role prompts.

Shipshape also includes an optional Pi extension template at `adapters/pi-extension.ts`. The extension registers `/captain`, `/qm`, `/crew`, and `/clearrole` commands and injects the selected role instructions into the session prompt.

## Minimal Setup

1. Add `AGENTS.md` from `templates/AGENTS.md` to the project.
2. Fill in the placeholders for commands and directories.
3. Keep `agents/captain.md`, `agents/quartermaster.md`, and `agents/crew-mate.md` available.
4. Start the correct role by loading or pasting the matching role prompt.

## Optional Pi Slash Commands

To enable slash commands in Pi:

1. Copy `adapters/pi-extension.ts` to the target project as `.pi/extensions/shipshape-roles.ts`.
2. Keep command prompts available at either:
   - `commands/captain.md`, `commands/qm.md`, `commands/crew.md`, or
   - `.claude/commands/captain.md`, `.claude/commands/qm.md`, `.claude/commands/crew.md`.
3. Optionally keep `agents/crew-mate.md` available for richer `/crew` instructions.
4. Run `/reload` in Pi.

The extension provides:

- `/captain [topic]`
- `/qm [optional focus]`
- `/crew <failing target>`
- `/clearrole`

The `/qm` command includes a best-effort guard: if `/captain` was used earlier in the same Pi session, `/qm` refuses to start and tells the user to open a fresh session.

## Recommended Use

- Use Captain sessions for all human discussion and spec changes.
- Use fresh/cleared Quartermaster sessions to generate and maintain tests. Do not run Quartermaster in a Captain conversation.
- Use Crew Mate sessions to make a single failing target pass.

## No Subagent Dispatch

If Pi cannot dispatch subagents, either run Crew Mates manually or allow the documented Quartermaster fallback.

## Notes

The Pi extension is intentionally generic. It avoids project-specific commands, test runners, and product names. Put project-specific commands in `AGENTS.md`, `HANDOVER.md`, and the role command prompts.

# Pi Adapter

Pi agent environments can use Shipshape as plain text workflow instructions plus role prompts.

Because Pi deployments may differ, this adapter avoids assuming a specific command or plugin system.

## Minimal Setup

1. Add `AGENTS.md` from `templates/AGENTS.md` to the project.
2. Fill in the placeholders for commands and directories.
3. Keep `agents/captain.md`, `agents/quartermaster.md`, and `agents/crew-mate.md` available.
4. Start the correct role by loading or pasting the matching role prompt.

## Recommended Use

- Use Captain sessions for all human discussion and spec changes.
- Use fresh/cleared Quartermaster sessions to generate and maintain tests. Do not run Quartermaster in a Captain conversation.
- Use Crew Mate sessions to make a single failing target pass.

## No Subagent Dispatch

If Pi cannot dispatch subagents, either run Crew Mates manually or allow the documented Quartermaster fallback.

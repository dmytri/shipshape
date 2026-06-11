# Cursor Adapter

Cursor can use Shipshape as repository instructions plus reusable role prompts. Exact Cursor features may vary by version and workspace configuration, so this adapter avoids depending on a specific extension API.

## Recommended Project Layout

```text
<project>/AGENTS.md
<project>/HANDOVER.md
<project>/.cursor/rules/shipshape.md          # optional, if your Cursor setup uses rules
<project>/shipshape/agents/captain.md         # optional copied role prompt
<project>/shipshape/agents/quartermaster.md   # optional copied role prompt
<project>/shipshape/agents/crew-mate.md       # optional copied role prompt
```

## Minimal Setup

1. Copy `templates/AGENTS.md` to `<project>/AGENTS.md` and fill in the placeholders.
2. Copy `templates/HANDOVER.md` if you want durable current-state handoff.
3. Keep the role prompts from `agents/` available in the repository or paste/reference them in Cursor chats.
4. If your Cursor setup uses project rules, add a rule that points agents to `AGENTS.md` and the Shipshape role prompts.

## Using Roles in Cursor

### Captain

Start a Cursor chat with the Captain prompt from `agents/captain.md`.

Use this for:

- human-facing discovery,
- writing or updating specs,
- resolving blockers,
- updating `AGENTS.md` or durable project instructions.

### Quartermaster

Before starting Quartermaster, clear the Captain chat or open a new Cursor chat/session.

This is mandatory: the Quartermaster must not inherit Captain/human discovery context. It should read only committed specs, tests, instructions, and explicit durable handoff files.

Start the new chat with the Quartermaster prompt from `agents/quartermaster.md`.

### Crew Mate

Use a separate focused chat with `agents/crew-mate.md` for one failing verification target.

Good target:

```text
Make <focused failing test/scenario> pass. Read committed specs and tests for behavior.
```

Avoid broad prompts such as:

```text
Implement the whole feature.
```

## Rules File Pattern

If you keep a Cursor rules file, use language like:

```md
This project uses Shipshape.
Read AGENTS.md before substantive work.
Use Captain for human-facing spec work.
Use Quartermaster only in a fresh/cleared chat after Captain.
Use Crew Mate for one failing test/scenario at a time.
Do not rely on prior chat for product requirements.
```

## No Subagent Dispatch

If Cursor cannot dispatch separate Crew Mate agents in your setup, run Crew Mate chats manually. If manual Crew sessions are impractical, document Quartermaster fallback in `HANDOVER.md` before allowing QM to implement after writing failing tests.

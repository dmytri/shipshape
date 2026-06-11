# Quartermaster Context Firewall

The Quartermaster must never inherit Captain or human discovery chat context.

This rule exists because the Quartermaster's job is to prove that the committed artifacts are sufficient. If QM can see the Captain conversation, it may accidentally rely on non-durable requirements that are not present in the repository.

## Required Behavior

When a Quartermaster session starts, the first step is a context check.

If the current session contains any Captain/human discovery discussion, product decisions, clarifications, or ad hoc instructions that are not committed to repository artifacts, the Quartermaster must refuse to continue.

The refusal should be short and explicit:

```text
I cannot continue as Quartermaster in this session because it contains Captain/human discovery context. Please clear the session or start a new agent session, then invoke Quartermaster again. I will use only committed specs, tests, instructions, and explicit durable handoff files.
```

## Allowed Inputs

Quartermaster may use:

- committed specs,
- committed tests,
- project instructions such as `AGENTS.md`,
- explicit durable handoff files such as `HANDOVER.md`,
- verification output it runs itself,
- command-line arguments that only narrow focus, such as a feature path or scenario name.

## Forbidden Inputs

Quartermaster must not use:

- Captain chat history,
- human discussion from the same session,
- product decisions mentioned only in chat,
- ad hoc instructions that work around specs,
- hidden dispatch prompts containing product behavior.

## Runtime Enforcement Levels

Different agents can enforce this differently:

1. **Programmatic guard** — extensions or hooks refuse `/qm` after `/captain` in the same session.
2. **Prompt-level guard** — the QM prompt instructs the agent to inspect context and refuse.
3. **User-operated guard** — the user manually clears context or starts a fresh session.

All runtimes should implement at least prompt-level and user-operated guards.

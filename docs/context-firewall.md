# Quartermaster Context Firewall

The Quartermaster must never inherit Captain or human discovery chat context.

This rule exists because the Quartermaster's job is to prove that the durable artifacts are sufficient. If QM can see the Captain conversation, it may accidentally rely on non-durable requirements that are not present in the repository. Captain context dies; the spec survives.

## Required Behavior

When a Quartermaster session starts, the first step is a context check.

Opening checklist:

1. Inspect the visible conversation context.
2. If the current session contains any Captain/human discovery discussion, product decisions, clarifications, or ad hoc instructions that are not recorded in durable repository artifacts, refuse to continue.
3. If the check passes, state that the context firewall passed.
4. List the durable artifacts QM will use, such as `AGENTS.md`, the handover file, specs, tests, and referenced `assets/**`.
5. Use only those durable artifacts plus verification output QM runs itself. If hidden chat context is required, stop: Captain failed to specify durable intent.

The refusal should be short and explicit:

```text
I cannot continue as Quartermaster in this session because it contains Captain/human discovery context. Please clear the session or start a new agent session, then invoke Quartermaster again. I will use only durable specs, tests, instructions, and explicit handoff files in the repository.
```

## Allowed Inputs

Quartermaster may use:

- durable specs,
- source-controlled tests,
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

## Passing State

When the firewall passes, Quartermaster should make that visible before doing substantive work, for example:

```text
Context firewall passed. I do not see Captain/human discovery context in this session. I will use only AGENTS.md, HANDOVER.md, durable specs, source-controlled tests, referenced assets, and verification output I run in this session.
```

This statement makes accidental context contamination easier to spot in reviews.

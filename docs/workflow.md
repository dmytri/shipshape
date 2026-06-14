# Shipshape Workflow

Shipshape is context-isolated spec-driven development for coding agents. It separates work into focused roles: Captain, Quartermaster, Crew Mate, and Bosun.

**Specs are durable. Code is disposable. Agents are replaceable.**

The handoff is the product. Each role leaves durable repository state so the next role can continue without hidden chat context.

## The one hard context boundary

Shipshape has one mandatory context reset:

```text
Captain -- clear/start fresh --> Quartermaster
```

Captain is human-facing and may contain product discovery chat. Quartermaster must not inherit that context. Captain tells the user to clear the session or start a fresh session before QM; QM enforces the context firewall and refuses if Captain/human discovery context is visible.

After QM starts clean, QM, Crew, Bosun, and Captain may transition by loading the next role skill in the same session because their context is derived from durable repo artifacts and verification output.

```text
Captain --clear--> QM <--> Crew --> QM --> Bosun --> Captain
```

If QM, Crew, or Bosun encounters missing or contradictory product intent, it loads Captain with the concrete blocker context. Captain updates durable artifacts. After Captain resolves product/spec intent, clear again before returning to QM.

## Durable repo artifacts

Durable intent and handoff artifacts include:

- `<spec directory>/**/*.feature` — valid executable Gherkin / BDD contracts,
- `AGENTS.md` — project/agent instructions, commands, directories, and conventions,
- `HANDOVER.md` — durable context transfer and next-step state,
- `assets/**` — Captain/human-authored durable supporting material,
- blocker reports,
- future `design-cards/**` — visual/design acceptance where Gherkin is the wrong format.

Source-controlled tests, fixtures, harnesses, and implementation code are also repo artifacts, but code remains disposable: regenerate or replace it when durable specs and verification demand it.

Use standards where they exist. Use sidecars where they do not. Do not invent fake-standard formats.

## Role loop

```text
Human ↔ Captain
Captain → durable intent artifacts
clear session / start fresh agent
Quartermaster → executable verification from artifacts only
Crew Mate → minimal implementation for one failing target
Quartermaster → verifies the target/result
Bosun → repo hygiene + local commit
Captain → human-approved outbound offer if completed work is clean
```

For a compact one-page summary of the start sequence, role transitions, config blocks, and blocker format, see `docs/quick-reference.md`. For a concrete walkthrough, see `docs/golden-path.md`.

## Captain phase

Use Captain for human/product discussion, durable specs/assets/instructions, blocker resolution, and post-Bosun outbound decisions. If the deck is unready, Captain loads Bosun before continuing. When QM is next, Captain tells the user to clear the session — this is the only mandatory clear in the workflow.

## Quartermaster phase

Use Quartermaster to convert specs into executable coverage and drive verification. QM starts with the context firewall check: refuses if Captain/human discovery context is visible; if clean, states the durable artifacts it will use. QM loads Crew for one failing target and loads Bosun when verification passes.

## Crew Mate phase

Use Crew for one failing implementation target.

Crew starts from failing verification and existing durable specs/tests. Crew changes the smallest production code needed for that target. When the target passes, Crew loads QM and becomes Quartermaster again, or reports back if running as a subagent.

## Bosun phase

Use Bosun after verification passes or when Captain finds a dirty deck. Bosun checks stale changed-file-adjacent artifacts, reruns verification, stages intended changes, and commits locally. After a clean commit, Bosun loads Captain for outbound decisions.

## Blocker loop

If QM, Crew, or Bosun cannot continue from durable repo artifacts alone, it loads Captain with the concrete blocker context. The report should name the target, evidence, commands tried, exact blocker, why continuing would require guessing, and the suggested Captain resolution.

Captain uses that evidence, updates durable artifacts, and then the user clears before returning to QM. This keeps product decisions visible in source control.

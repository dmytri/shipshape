# Shipshape Quick Reference

**Specs are durable. Code is disposable. Agents are replaceable.**

One hard boundary. Load-based role transitions. Outbound only with human approval.

---

## The One Hard Boundary

```text
Captain  --clear/fresh session-->  Quartermaster
```

Only this transition requires a cleared context. After QM starts clean, all later role transitions happen by loading the next role skill inside the same session — no additional clear required unless Captain resolves new product/spec intent.

---

## Minimal Start Sequence

```text
/captain  describe the feature or change
          → Captain writes durable specs/assets and optional Captain-only notes.
          → Captain tells you to clear before QM.

# Clear the session or start a fresh session here.

/qm       optional focused area
          → QM enforces context firewall, then starts from verification discovery.
          → QM writes verification exactly matching scenario steps, finds failing target, loads Crew.
          → Crew makes target pass, loads QM again.
          → QM verifies, loads Bosun.
          → Bosun cleans, commits locally, loads Captain.
          → Captain offers human-approved outbound next steps.
```

That is the full loop. The only prompt the human must give is:
1. `/captain` — start of discovery.
2. Clear/fresh session.
3. `/qm` — start of verification.

After that, roles load each other until Captain offers outbound options.

---

## Role Transitions at a Glance

```text
Captain ──clear──► QM ◄──────────────────────────────┐
                    │                                  │
                    │  load Crew (one failing target)  │
                    ▼                                  │
                  Crew ──── target passes ──► load QM ─┘
                    │
              (all targets pass)
                    │
                    ▼
                  QM ──► load Bosun
                              │
                    deck clean + local commit
                              │
                              ▼
                          Bosun ──► load Captain
                                        │
                              human-approved outbound
                              push / PR / publish / deploy
```

Blocker path (any post-QM role):

```text
QM / Crew / Bosun  ──► load Captain (with blocker context)
                              │
                    Captain updates durable artifacts
                              │
                           clear again
                              │
                             QM
```

---

## AGENTS.md Quick-Config Block

Add this table to your project's `AGENTS.md` and fill in each value:

```markdown
| Placeholder                      | Project value         |
|----------------------------------|-----------------------|
| `<spec directory>`               | `features/`           |
| `<test directory>`               | `tests/`              |
| `<implementation directory>`     | `src/`                |
| `<asset directory>`              | `assets/`             |
| `<verification discovery command>` | `<command or N/A>` |
| `<test command>`                 | `<command>`           |
| `<focused test command>`         | `<command>`           |
| `<typecheck command>`            | `<command or N/A>`    |
| `<lint command>`                 | `<command or N/A>`    |
```

Also add the Shipshape workflow requirement block from `templates/shipshape-agents-block.md` so future agents know Shipshape must be installed or loaded before substantive work. Copy `templates/CAPTAIN.md` only if the project wants a Captain-only notes file; QM, Crew, and Bosun must not read it.

---

## Blocker Report: Minimal Format

When QM, Crew, or Bosun cannot continue without guessing product intent:

```markdown
## Blocker

**Role:** `<Quartermaster | Crew Mate | Bosun>`
**Target:** `<feature / scenario / test>`
**Exact blocker:** `<one sentence>`
**Why I cannot continue:** `<one sentence about the missing decision>`
**Suggested Captain resolution:** `<what durable artifact to update>`
```

Load Captain with this context. Captain updates durable artifacts. Clear before returning to QM.

---

## Outbound Decision Point

Captain is the only role that offers outbound actions. The trigger is Bosun reporting:

- implementation verification passing,
- a clean deck,
- a local commit.

Captain summarizes the completed work and offers options for human approval:

```text
Work is committed as <hash>. Would you like to push the branch, open a PR,
publish a release, deploy, or leave it local?
```

Captain performs outbound actions only when the human explicitly approves and project instructions allow them.

---

## Install

```bash
# skills.sh (Zed, Claude Code, Cursor, Codex, OpenCode, and more)
npx skills add dmytri/shipshape --skill '*'
```

See `adapters/README.md` for the full support matrix and runtime-specific notes.

---

## Further Reading

| Doc | Purpose |
|-----|---------|
| `docs/golden-path.md` | Smallest complete Captain → QM → Crew → QM → Bosun → Captain example |
| `docs/workflow.md` | Full workflow description |
| `docs/adoption-guide.md` | How to add Shipshape to an existing project |
| `docs/adoption-checklist.md` | Readiness checklist |
| `docs/context-firewall.md` | QM fresh-context refusal behavior |
| `templates/AGENTS.md` | Agent/tooling configuration template |
| `templates/CAPTAIN.md` | Optional Captain-only notes template |
| `templates/blocker-report.md` | Detailed blocker report format |

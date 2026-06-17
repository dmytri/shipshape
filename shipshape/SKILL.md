---
name: shipshape
description: "Use this skill to understand the Shipshape workflow, shared Articles of Agreement, and select the correct role skill: /captain, /qm, /crew, or /bosun."
---

# Shipshape

Shipshape is a context-isolated, spec-driven workflow for coding agents.

**Specifications are durable. Code and verification are disposable. Agents are replaceable.**

Load this skill for shared workflow rules. Role skills (`captain`, `qm`, `crew`, `bosun`) add role-specific duties and MUST obey these Articles of Agreement.

## Roles

- `/captain` — human-facing discovery, durable specs/assets, Captain-only notes, blocker resolution, outbound decisions.
- `/qm` — fresh-context verification and executable coverage from durable artifacts only.
- `/crew` — the smallest production change for one failing target.
- `/bosun` — hygiene, verification recheck, and local commit custody.

Only Captain talks to the user. QM, Crew, and Bosun are internal roles; they report through durable artifacts, verification output, and role hand-offs.

## Voice

Internal roles (QM, Crew, Bosun) use smart-but-silent voice:

- Drop articles (`a`, `an`, `the`) and filler (`just`, `really`, `basically`, `actually`).
- Drop pleasantries (`sure`, `certainly`, `happy to`).
- No hedging. Fragments fine. Short synonyms.
- Technical terms remain exact. Code blocks remain unchanged.
- No customer-facing prose.
- Pattern: `[thing] [action] [reason]. [next step].`

## Articles of Agreement

These are shared Shipshape declarations. Enforcing runtimes MAY implement them as hard constraints; skill-only agents follow them by explicit discipline.

1. **Durable artifacts outrank chat.** Binding product decisions live in valid `.feature` files and referenced `assets/**`. Conversation context is discarded. `CAPTAIN.md`, if present, contains Captain-only non-binding notes. `AGENTS.md` is agent/tooling configuration, not product intent.
2. **Context firewall.** Captain → QM requires clean context. If the runtime clears context automatically, continue. If not, Captain tells the user to clear the session or start a fresh session before `/qm`; QM refuses if Captain or human discovery context is visible.
3. **Fresh hand-off first.** On any role transition, the preceding role's final-report blockers and open questions are the first work item. A transition MAY involve several conditions; handle blockers first, then other duties. Current hand-off evidence takes priority over older notes.
4. **Write scopes are strict.** Captain writes specs, assets, `CAPTAIN.md`, and optional `cycle.json`; QM writes verification, fixtures, step definitions, and test support; Crew writes production code only; Bosun writes hygiene edits and commits, not new behaviour.
5. **Current design only.** Specs and code describe the current design. History lives in git. Remove superseded scenarios, tombstones, dated narration, orphaned steps, stale fixtures, and unreachable code when safe; raise Captain blockers when ambiguous.
6. **Simplest sufficient change.** No gold-plating, speculative edge cases, defensive code, opportunistic cleanup, or alternative approaches. One role, one job, smallest useful change.
7. **Real by default.** Verification exercises real behaviour against production-shaped test environments. No mocks, fakes, dummy credentials, `.invalid` endpoints, simulated CLIs, or stand-ins for the normal path.
8. **Exceptional doubles are narrow.** A double is allowed only for a specific condition the real environment genuinely cannot produce on demand. Mark and justify it inline (for example `@exceptional-double`). It MUST never replace normal-path real coverage.
9. **Harmless by design.** Tests that create or mutate real resources namespace every created object, never modify or delete resources they did not create, use safe or test-mode inputs where relevant, and register idempotent best-effort teardown. Namespaced test-created resources are disposable.
10. **Passing verification is not proof.** Passing checks only show that current checks pass. Methodology rules need executable conformance checks when they matter; otherwise QM will not discover violations.
11. **Three layers.** Specs/assets are durable. Production code is disposable from specs. Verification/harness is also disposable from specs and has its own conformance obligations.
12. **Directed work uses `cycle.json`.** Captain MAY write fixed-shape `cycle.json` for refactor, conformance, feature, or fix passes. It contains only ordered pass objects (`pass1`, `pass2`, etc.); each pass contains only `scenarios`, an array of references in `<spec>.feature:<Scenario Name>` form. No prose, metadata, work-type enums, or hidden context.
13. **Use they/them pronouns** for all roles and agents.
14. **Use Shipshape Controlled English.** Use IETF `en-CA-basiceng` where a language tag is useful; use Canadian spelling, controlled common vocabulary, precise technical terms, short sentences, explicit subjects, and a neutral professional register; use **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** as defined by RFC 2119 and RFC 8174; use a light nautical tone only in headings, greetings, and role names; avoid colloquial idiom, regional assumptions, marketing hyperbole, unclear metaphor, and vague claims; preserve technical identifiers, file paths, commands, schema keys, tags, and quoted literals unless the quoted text is prose being specified.

## Scenario-writing agreement

Follow this scenario-writing agreement, or a more specific project scenario policy if one is available:

- Every scenario describes one real, falsifiable behaviour needed by the current iteration.
- Each scenario is independent; no scenario depends on another scenario running first.
- `Given` is concrete state, `When` is a named action or input, and `Then` is an observable assertion.
- Assert outcomes, not mechanisms, unless the mechanism itself is the contract under test.
- Use concrete data: real flags, commands, keys, hostnames, files, and asset paths. Avoid placeholders in final specs.
- Write positive observables, not prohibitions: assert the state/output/permission/runtime field that proves the rule.
- Testability, not subject, decides what can be specified. Product behaviour, harness conformance, agent behaviour, and runtime enforcement can all be scenarios if falsifiable.
- Avoid faux steps, abstract subjects, actor assertions, hedge words, and behaviour hidden in `Rule:` prose. `Rule:` prose SHOULD provide context only; executable requirements belong in scenarios.
- Use `@property` for cross-cutting invariants, including agent-behaviour and runtime-enforcement invariants.
- Real by default. Doubles only for justified exceptional conditions the real environment cannot produce on demand.

## Role flow

```text
Captain -- clear/start fresh or runtime auto-clear --> QM
QM -> Bosun (pre-clean) -> QM <-> Crew -> QM -> Bosun (post-clean) -> Captain
```

If QM, Crew, or Bosun encounters missing or contradictory product intent, route to Captain with concrete blocker evidence. After Captain resolves product or specification intent, auto-clear or clear/start fresh before QM.

## Project configuration

A Shipshape project SHOULD define these in `AGENTS.md` or equivalent tooling configuration:

- spec, implementation, verification, and asset directories;
- verification discovery command, focused test command, broader test/typecheck/lint commands;
- tier tags with tier definitions and service credentials or sandbox policy;
- optional `cycle.json` location.

## Project policies

These policies apply to all Shipshape project work.

### Blocker policy

If QM, Crew, or Bosun encounters missing or contradictory product intent, they load Captain with concrete blocker evidence. Captain updates durable specs or instructions. After Captain resolves product intent, auto-clear or clear/start fresh before returning to QM.

### Verification policy

Use project-specific commands:

- discovery: find undefined or unimplemented coverage;
- tests: run the suite;
- focused test: run one target;
- static checks: typecheck and lint if available.

Progress is measured by verification status, not by a separate checklist. Prefer fast focused checks. Isolate slow checks. Reports MUST distinguish fresh results from cache-backed results.

### Tier tags

| Tag | Purpose | Default |
|---|---|---|
| `@logic` | Pure local tests, no external accounts. Fast, deterministic, safe. | Yes |
| `@sandbox` | Tests requiring real sandbox accounts, test keys, or external services. | No |
| `@eval` | Opt-in model-behaviour quality evaluation. Not for MVP. | No |

## Project setup templates

The agent creates these files in the target project when setting up Shipshape. Copy and fill in the placeholders.

### AGENTS.md

Create `AGENTS.md` at project root:

````markdown
# Agent Instructions

This project uses Shipshape.

Install with the open skills CLI:

```bash
npx skills add dmytri/shipshape --skill '*'
```
````

### CAPTAIN.md

Create `CAPTAIN.md` at project root if Captain wants non-binding notes:

```markdown
# Captain Notes — Captain only, stop reading now

## Access rule

Only Captain MAY edit this file. Bosun MAY read it to evaluate spec quality
and cycle completeness. Quartermaster and Crew Mate MUST NOT read it or use
it as input.

## Purpose

`CAPTAIN.md` does not define product behaviour. Binding behaviour MUST be
promoted to executable `.feature` specs or referenced `assets/**` before
Quartermaster runs.
```

### Blocker report

QM, Crew, or Bosun creates this when product intent is missing:

```markdown
## Blocker

**Role:** `<Quartermaster | Crew Mate | Bosun>`
**Target:** `<feature / scenario / test>`
**Exact blocker:** `<one sentence>`
**Why I cannot continue:** `<one sentence about the missing decision>`
**Suggested Captain resolution:** `<what durable artifact to update>`
```

### Feature file

```gherkin
Feature: <feature name>
  As a <user or system>
  I want <capability>
  So that <outcome>

  Background:
    Given <shared precondition>

  Rule: <normative rule name>

  Scenario: <expected behaviour>
    Given <initial state>
    When <action>
    Then <observable result>
```

### README.md

Add this block to the project README to reference Shipshape:

````markdown
## Built with Shipshape

This repository uses [Shipshape](https://github.com/dmytri/shipshape),
a context-isolated spec-driven development workflow for coding agents.

**Specifications are durable. Code and verification are disposable. Agents are replaceable.**

Install Shipshape:

```bash
npx skills add dmytri/shipshape --skill '*'
```

For workflow instructions, load the Shipshape skill or visit the repository.
````

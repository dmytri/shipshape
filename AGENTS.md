# Agent Instructions for Shipshape

This repository contains the Shipshape skill package. These instructions are for agents editing this repository, not for projects using Shipshape.

Agents using Shipshape should treat this entire repository as Captain/human-owned material, like `assets/**` in an adopting project: edit it only when explicitly asked, and do not treat it as disposable implementation or verification.

## Scope

Shipshape is distributed as skill files:

| Path | Purpose |
|---|---|
| `skills/shipshape/SKILL.md` | Shared workflow rules and project setup templates |
| `skills/captain/SKILL.md` | Captain role skill |
| `skills/qm/SKILL.md` | Quartermaster role skill |
| `skills/crew/SKILL.md` | Crew Mate role skill |
| `skills/boatswain/SKILL.md` | Boatswain role skill |
| `skills/shipwright/SKILL.md` | Shipwright role skill |
| `.plugin/plugin.json` | Vendor-neutral plugin manifest |
| `agents/` | Role agents for context isolation (thin adapters over role skills) |
| `hooks/` | Custody enforcement hooks (mechanize Article text only) |
| `README.md` | Public project positioning and usage overview |
| `skills.sh.json` | skills.sh registry metadata |
| `AGENTS.md` | Repository-local agent instructions |

## Editing rules

- Keep repository guidance separate from downstream Shipshape usage guidance.
- Put public positioning in `README.md`.
- The README slogan is "Specifications are durable. Code is disposable. Agents are replaceable." It is a slogan, not doctrine. Keep it punchy. Do not rewrite it to match skill wording; the skills carry the precise three-layer doctrine.
- Put shared workflow rules in `skills/shipshape/SKILL.md`.
- Put role-specific rules in the matching role skill.
- Keep all role skills consistent with the Articles of Agreement in `skills/shipshape/SKILL.md`.
- Skills alone MUST fully instruct agents. The plugin layer (`.plugin/`, `agents/`, `hooks/`) only mechanizes what skill text already states. Every plugin artifact cites the skill text it enforces. Adding behaviour to the plugin layer that the skills do not state is a violation; fix the skill first, then mechanize it. Deleting the plugin layer must lose nothing but enforcement.
- Use Shipshape Controlled English in skill files: short sentences, precise subjects, RFC 2119 terms where useful, and Canadian spelling such as `behaviour`. Use `artifact`, not `artefact`.
- Do not add project-specific assumptions from Jolly, Saleor, or other adopters to shared Shipshape rules.
- Do not create binding repository artifacts such as roadmaps, memory banks, decision logs, constitutions, or task lists unless the user explicitly asks.
- Do not update installed global skills or downstream project copies unless the user explicitly asks.
- Do not commit or push unless the user explicitly asks.

## Commit attribution

Do not add agent-specific authorship, committer identity, or `Co-authored-by` trailers for coding agents. Commits should use `Dmytri Kleiner <dev@dmytri.to>` unless the maintainer explicitly instructs otherwise.

## Validation

Before reporting a documentation change as complete:

- run diagnostics for changed Markdown files when available;
- search for stale names or project-specific leakage when relevant;
- check `git diff` for accidental duplication or unrelated edits.

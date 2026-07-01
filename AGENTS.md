# Agent Instructions for Shipshape

This repository contains the Shipshape skill package. These instructions are for agents editing this repository, not for projects using Shipshape.

Agents using Shipshape should treat this entire repository as Captain/human-owned material, like `assets/**` in an adopting project: edit it only when explicitly asked, and do not treat it as disposable implementation or verification.

## Scope

Shipshape is distributed as skill files:

| Path | Purpose |
|---|---|
| `shipshape/SKILL.md` | Shared workflow rules and project setup templates |
| `captain/SKILL.md` | Captain role skill |
| `qm/SKILL.md` | Quartermaster role skill |
| `crew/SKILL.md` | Crew Mate role skill |
| `boatswain/SKILL.md` | Boatswain role skill |
| `README.md` | Public project positioning and usage overview |
| `skills.sh.json` | skills.sh registry metadata |
| `AGENTS.md` | Repository-local agent instructions |

## Editing rules

- Keep repository guidance separate from downstream Shipshape usage guidance.
- Put public positioning in `README.md`.
- Put shared workflow rules in `shipshape/SKILL.md`.
- Put role-specific rules in the matching role skill.
- Keep all role skills consistent with the Articles of Agreement in `shipshape/SKILL.md`.
- Use Shipshape Controlled English in skill files: short sentences, precise subjects, RFC 2119 terms where useful, and Canadian spelling such as `behaviour`. Use `artifact`, not `artefact`.
- Do not add project-specific assumptions from Jolly, Saleor, or other adopters to shared Shipshape rules.
- Do not create binding repository artifacts such as roadmaps, memory banks, decision logs, constitutions, or task lists unless the user explicitly asks.
- Do not update installed global skills or downstream project copies unless the user explicitly asks.
- Do not commit or push unless the user explicitly asks.

## Validation

Before reporting a documentation change as complete:

- run diagnostics for changed Markdown files when available;
- search for stale names or project-specific leakage when relevant;
- check `git diff` for accidental duplication or unrelated edits.

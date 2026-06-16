# Shipshape Repository

This repository **is** the Shipshape workflow tool. It does not use the Shipshape workflow to develop itself.

## Repository type: assets

The entire repository is a single `assets/` directory. All content is Captain-owned, directly authored, and durable — exactly like the `assets/**` that Shipshape defines for adopting projects.

There are no specs (no `.feature` files), no verification harness, no `cycle.json`, no implementation code, no disposable layers. There is nothing for QM, Crew, or Bosun to do. The whole repo sits in the durable-Captain-authored layer.

## What lives here

All files are directly authored by Captain — edit anything, commit directly.

| Path | What |
|---|---|
| `captain/SKILL.md` | Captain role skill prompt |
| `qm/SKILL.md` | Quartermaster role skill prompt |
| `crew/SKILL.md` | Crew Mate role skill prompt |
| `bosun/SKILL.md` | Bosun role skill prompt |
| `shipshape/SKILL.md` | Orientation/router skill |
| `docs/` | Workflow docs, quick reference, adoption guide, etc. |
| `templates/` | Bootstrap templates for adopting projects |
| `adapters/` | Runtime-specific adapters (Pi, etc.) |
| `packages/` | Distribution packages (pi-shipshape, etc.) |
| `README.md` | Public-facing project description |
| `AGENTS.md` | This file — agent instructions for working on Shipshape |
| `skills.sh.json` | skills.sh registry metadata |

## Key principle

Shipshape skills are **declarations** that tell agents and runtimes what roles should and should not do. They cannot enforce anything on their own — enforcing runtimes (like Estelle) implement the constraints. This repo ships the declarations.

## Pronouns

All roles referenced in skills and docs use they/them pronouns.

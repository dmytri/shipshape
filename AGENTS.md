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
| `commands/` | Plugin slash commands (derived-state reporting and install diagnostics, no doctrine) |
| `assets/logo.svg` | Plugin logo |
| `tests/` | Hook behaviour, map drift, and firewall conformance tests |
| `README.md` | Public project positioning and usage overview |
| `llms.txt` | Agent-facing index of canonical files (pointers only, no doctrine) |
| `shipshape.md` | Structural orientation map (names, relations, pointers; non-normative) |
| `skills.sh.json` | skills.sh registry metadata |
| `AGENTS.md` | Repository-local agent instructions |

## Editing rules

- Keep repository guidance separate from downstream Shipshape usage guidance.
- Put public positioning in `README.md`.
- The README slogan is "Specifications are durable. Code is disposable. Agents are replaceable." It is a slogan, not doctrine. Keep it punchy. Do not rewrite it to match skill wording; the skills carry the precise three-layer doctrine.
- Put shared workflow rules in `skills/shipshape/SKILL.md`.
- Put role-specific rules in the matching role skill.
- Keep all role skills consistent with the Articles of Agreement in `skills/shipshape/SKILL.md`.
- `shipshape.md` is a structural map: names, relations, and pointers only. A normative sentence in it is a defect. Update it with any rename it references; `tests/map.sh` checks the names against the skills.
- Bump the `version` in `.plugin/plugin.json` with any plugin-layer change: `.plugin/`, `agents/`, `hooks/`, `commands/`, `assets/`, or `shipshape.md`.
- Enforcement claims are per-runtime. Claim a mechanism for a runtime only after live-fire verification on that runtime; name unverified runtimes unsupported for enforcement.
- Skills alone MUST fully instruct agents. The plugin layer (`.plugin/`, `agents/`, `hooks/`) only mechanizes what skill text already states. Every plugin artifact cites the skill text it enforces. Adding behaviour to the plugin layer that the skills do not state is a violation; fix the skill first, then mechanize it. Deleting the plugin layer must lose nothing but enforcement.
- Use Shipshape Controlled English in skill files: short sentences, precise subjects, RFC 2119 terms where useful, and Canadian spelling such as `behaviour`. Use `artifact`, not `artefact`.
- The README Ship of Theseus section is the only text with relaxed Controlled English rules, for literary effect. Every other file follows Controlled English in full, including the punctuation rules: no em dashes and no parenthetical asides.
- Do not add project-specific assumptions from Jolly, Saleor, or other adopters to shared Shipshape rules.
- Do not create binding repository artifacts such as roadmaps, memory banks, decision logs, constitutions, or task lists unless the user explicitly asks.
- Do not update installed global skills or downstream project copies unless the user explicitly asks.
- Do not commit or push unless the user explicitly asks.

## Plugin format

The plugin layer follows the vendor-neutral open-plugin specification, not Claude Code's native plugin layout. This is a deliberate early-adopter choice. The format is new and its adoption is uncertain, so anchor on Claude Code as the one live-fire-verified runtime and support the neutral format where it costs nothing.

- Spec: https://github.com/vercel-labs/open-plugin-spec
- Installer: https://www.npmjs.com/package/plugins, run as `npx plugins add dmytri/shipshape`

Rules that follow from the format:

- The manifest lives at `.plugin/plugin.json`. The spec requires hosts to check that path, and the `plugins` installer reads it as the source of truth. Component directories such as `skills/`, `agents/`, `hooks/`, and `commands/` live at the plugin root, never inside `.plugin/`.
- Do not add a `.claude-plugin/plugin.json` to the repository. On install, `npx plugins add` copies `.plugin/` to the vendor directory such as `.claude-plugin/`, generates `.claude-plugin/marketplace.json`, and registers the plugin in the runtime settings. The installer performs this translation only when no vendor manifest already exists, so a hand-written `.claude-plugin/plugin.json` would suppress the translation and create a second manifest to keep version-synced.
- `hooks/hooks.json` uses `${CLAUDE_PLUGIN_ROOT}` on purpose. It resolves natively on Claude Code even without the installer, and the installer rewrites it to the target vendor root such as `${CURSOR_PLUGIN_ROOT}` on other runtimes. Keep it Claude-anchored. Do not change it to the neutral `${PLUGIN_ROOT}`, which resolves only when the installer runs its translation.

## Commit attribution

Do not add agent-specific authorship, committer identity, or `Co-authored-by` trailers for coding agents. Commits should use `Dmytri Kleiner <dev@dmytri.to>` unless the maintainer explicitly instructs otherwise.

## Validation

Before reporting a documentation change as complete:

- run diagnostics for changed Markdown files when available;
- search for stale names or project-specific leakage when relevant;
- check `git diff` for accidental duplication or unrelated edits.

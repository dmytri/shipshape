# Handover

This file is the durable current-state handoff for Shipshape roles. The handoff is the product: if context matters after `/clear`, record it in durable repo artifacts.

## Shipshape Project Notices

- Bosun verified/restored the required Shipshape README block: `<yes/no/unknown>`
- Bosun verified/restored the required Shipshape AGENTS block: `<yes/no/unknown>`
- `assets/` policy is documented and protected: `<yes/no/unknown>`

## Durable Artifact Notes

- Product intent lives in valid Gherkin `.feature` files or other explicit durable spec artifacts, not hidden chat.
- Project conventions live in `AGENTS.md`.
- Supporting material lives in `assets/**`.
- This file records current state and next steps; it must not be the only place product requirements exist.
- Use standards where they exist. Use sidecars where they do not.

## Environment Notes

- Crew Mate dispatch available: `<yes/no/unknown>`
- Bosun dispatch available: `<yes/no/unknown>`
- If Crew dispatch is unavailable, Quartermaster implementation fallback allowed: `<yes/no>`
- If the active harness cannot spawn or invoke a separate Bosun role, QM assumed Bosun duties as required fallback: `<yes/no/N/A>`
- Required credentials or services: `<list or N/A>`
- Known unavailable checks: `<list or N/A>`

## Bosun Status

- Bosun hygiene complete: `<yes/no/unknown>`
- Local commit created: `<yes/no/unknown>`
- Commit: `<hash and message or N/A>`
- Working tree clean: `<yes/no/unknown>`
- Nothing pushed/tagged/published/released: `<yes/no/unknown>`

## Current Verification Status

| Command | Result | Notes |
|---|---|---|
| `<verification discovery command>` | `<unknown>` | `<notes>` |
| `<test command>` | `<unknown>` | `<notes>` |
| `<typecheck command>` | `<unknown>` | `<notes>` |
| `<lint command>` | `<unknown>` | `<notes>` |

## Current Worklist

The Quartermaster should derive the real worklist from verification status. This section is only orientation.

1. `<item>`
2. `<item>`

## Recent Captain Changes

- `<spec or instruction change>`
- `<artifact deleted because it may be stale>`

## Known Blockers

Use `templates/blocker-report.md` format for detailed blockers. Each blocker should include the reporting role, target, files read, commands tried, exact blocker, why the role cannot continue without guessing, and suggested Captain resolution.

- `<blocker or none>`

## Notes for Next Role

- Next recommended role: `<Captain | Quartermaster | Crew Mate | Bosun>`
- If next role is Quartermaster, user must clear the current session or start a fresh agent first: `<yes/no/N/A>`
- Quartermaster should state context-firewall status and durable artifacts used: `<yes/no/N/A>`
- If next role is Crew Mate, exact failing target: `<test/scenario/command or N/A>`
- If next role is Bosun, completed target/change summary: `<summary or N/A>`
- Focus: `<topic/test/scenario>`

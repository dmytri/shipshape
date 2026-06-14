# Handover

This file is the durable current-state handoff for Shipshape roles. The handoff is the product: if context matters after `/clear`, record it in durable repo artifacts.

## Shipshape Project Notices

- Bosun verified/restored the required Shipshape README block: `<yes/no/unknown>`
- Bosun verified/restored the required Shipshape AGENTS block: `<yes/no/unknown>`
- `assets/` policy is documented and protected: `<yes/no/unknown>`

## Current Shipshape State

- Current target: `<feature/scenario/test or N/A>`
- Last completed role: `<Captain | Quartermaster | Crew Mate | Bosun | N/A>`
- Next role to load: `<Captain | Quartermaster | Crew Mate | Bosun | N/A>`
- Captain → QM clear required before next QM: `<yes / no / N/A>`
- Relevant specs: `<paths>`
- Relevant tests: `<paths>`
- Relevant implementation files: `<paths>`
- Deck status: `<clean / dirty / unknown>`
- Bosun hygiene complete: `<yes / no / unknown>`
- Bosun commit: `<hash and message or N/A>`
- Outbound action pending with Captain: `<yes / no / N/A>`

## Environment Notes

- Required credentials or services: `<list or N/A>`
- Known unavailable checks: `<list or N/A>`

## Current Verification Status

| Command | Result | Notes |
|---|---|---|
| `<verification discovery command>` | `<unknown>` | `<notes>` |
| `<test command>` | `<unknown>` | `<notes>` |
| `<typecheck command>` | `<unknown>` | `<notes>` |
| `<lint command>` | `<unknown>` | `<notes>` |

## Current Worklist

The Quartermaster should derive the real worklist from verification status. This section is orientation only.

1. `<item>`
2. `<item>`

## Recent Captain Changes

- `<spec or instruction change>`
- `<artifact deleted because it may be stale>`

## Known Blockers

Use `templates/blocker-report.md` format for detailed blockers.

- `<blocker or none>`

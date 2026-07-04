---
description: "Report Shipshape deck state derived from repository signals. Read-only."
---

# Shipshape status

This command mechanizes the derived-state rule from the Shipshape skills: harbour and deck state are derived from durable signals, never stored. Doctrine lives in the skills; this command adds none.

Derive current deck state from repository signals and report it. Run read-only checks. Change nothing.

1. Tree: run `git status --short` and, when an upstream exists, `git rev-list --count @{upstream}..HEAD`. Report working tree cleanliness and commits ahead of upstream.
2. Rigging: report whether `RIGGING.md` exists at the project root and whether the required values are present: `language` under Stack, `implementation` and `specs` under Directories, `focused` under Commands, and `fail-fast` under Perturbation.
3. Harbour signals: count `@captain` and `@shipwright` tags in the specs directory.
4. Perturbations: count `PERTURBATION` statements in the implementation directory.
5. Watchbill: report whether `watchbill.json` exists and matches the fixed shape Article 4 defines.
6. Report the signals as a short table. Close with the routing the `shipshape` skill defines: `RIGGING.md` absent routes to `/shipwright` for fitting out; a dirty tree needs Boatswain; otherwise Captain.

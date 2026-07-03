# Shipshape Map

> Orientation only. This map holds structure and pointers. The skills are canonical. Load the `shipshape` skill for the Articles of Agreement, and the role skill for its rules. When this map and a skill disagree, the skill wins.

## Roles

| Role | Skill | Writes | Hands off to |
|---|---|---|---|
| Captain | `captain` | `.feature` specs, `assets/**`, `CAPTAIN.md`, `watchbill.json`, perturbation statements | QM, across a context clear |
| Quartermaster | `qm` | verification: tests, step definitions, fixtures, harness | Crew, or Boatswain |
| Crew Mate | `crew` | production code only | QM |
| Boatswain | `boatswain` | hygiene edits, `@shipwright` scenario marks, local commits | Captain |
| Shipwright | `shipwright` | `@captain` skeletons, `@planks(...)` annotations, harbour removals, fitting-out `AGENTS.md` and `RIGGING.md` | Captain |

## Durable artifacts

| Artifact | Holds | Custody |
|---|---|---|
| `.feature` files | binding product behaviour | Captain |
| `assets/**` | human-owned product material | Captain, during Shipshape work |
| `AGENTS.md` | agent entry document | project |
| `RIGGING.md` | tooling values, per the fixed shape in the shipshape skill | Shipwright derives and repairs |
| `CAPTAIN.md` | Captain-only non-binding notes | Captain |
| `watchbill.json` | ordering of verification-discovered work | Captain |

## Gherkin tags, on scenarios

| Tag | Meaning |
|---|---|
| `@captain` | skeleton awaiting Captain review; excluded from verification |
| `@shipwright` | condemned scenario; harbour removes its planked code, then the scenario |
| `@property` | cross-cutting invariant |
| `@exceptional-double` | justified narrow double |
| `@logic`, `@sandbox` | verification tiers |

## Docblock annotations, in production code

`@planks("<Gherkin step>")` marks a seam that carries behaviour required by that exact step. It is the only docblock annotation.

## Rigging commands

`discover`, `focused`, `broad`, `coverage`, `step-usage`, `plank-inventory`, `typecheck`, `lint`. Values live in `RIGGING.md`.

## Flow

User to Captain: intent becomes durable specs. Context clears. QM discovers work from verification and dispatches Crew per failing target. Boatswain does hygiene, reverifies, and commits locally. Captain reports and handles outbound. Harbour: Shipwright inventories, Captain reviews.

## Routing

- `RIGGING.md` absent: `/shipwright` fits out.
- Working tree dirty: Boatswain cleans.
- Otherwise: `/captain`.

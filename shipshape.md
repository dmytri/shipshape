# Shipshape Map

> Orientation only. This map holds structure and pointers. The skills are canonical. Load the `shipshape` skill for the Articles of Agreement, and the role skill for its rules. When this map and a skill disagree, the skill wins.

Specifications are durable. Code is disposable. Agents are replaceable.

## Roles

| Role | Skill | Writes | Hands off to |
|---|---|---|---|
| Captain | `captain` | `.feature` specs, `assets/**`, `CAPTAIN.md`, `watchbill.json` | QM, across a context clear |
| Quartermaster | `qm` | verification: tests, step definitions, fixtures, harness | Crew, or Boatswain |
| Crew Mate | `crew` | production code only | QM |
| Boatswain | `boatswain` | hygiene edits and local commits | Captain |
| Shipwright | `shipwright` | `@captain` skeletons, `@planks(...)` annotations, harbour removals | Captain |

Only Captain talks to the user. The Captain to QM boundary requires clear context.

## Durable artifacts

| Artifact | Holds | Custody |
|---|---|---|
| `.feature` files | binding product behaviour | Captain |
| `assets/**` | human-owned product material | Captain, during Shipshape work |
| `AGENTS.md` | agent entry document | project |
| `RIGGING.md` | tooling values: stack, directories, commands, perturbation, tiers | Shipwright scaffolds, Captain amends |
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

| Annotation | Meaning |
|---|---|
| `@planks("<Gherkin step>")` | seam carries behaviour required by that exact step |
| `@shipwright` | spec-less dead seam awaiting harbour removal |

## Rigging commands

`discover`, `focused`, `broad`, `coverage`, `step-usage`, `plank-inventory`, `typecheck`, `lint`. Values live in `RIGGING.md`.

## Flow

User to Captain: intent becomes durable specs. Context clears. QM discovers work from verification and dispatches Crew per failing target. Boatswain does hygiene, reverifies, and commits locally. Captain reports and handles outbound. Harbour: Shipwright inventories, Captain reviews.

## Routing

- `RIGGING.md` absent: `/shipwright` fits out.
- Working tree dirty: Boatswain cleans.
- Otherwise: `/captain`.

# cycle.json

Optional QM worklist for directed (non-red-discoverable) cycles.

## When to use

The normal Shipshape loop works when QM can derive its worklist from undefined or failing verification targets. Some work is not red-discoverable:

- **Refactors** — behavior-preserving, green-guarded. No failing test exists.
- **Conformance seeding** — adding methodology/invariant checks that don't correspond to a spec scenario.
- **Dependent scenarios** — pass2 scenarios cannot be worked until pass1 scenarios are verified.

In these cases, Captain writes `cycle.json` to tell QM exactly which scenarios to work and in which order.

When absent, QM runs all scenarios (standard behavior).

## Schema

The schema lives at `schemas/cycle.json`. It enforces:

- Only `pass1`, `pass2`, etc. as top-level keys
- Each pass has only a `scenarios` array
- Each scenario ref matches `features/file.feature:Scenario Name` format
- No freeform text fields, no work type enums, no metadata
- At least `pass1` required

```json
{
  "pass1": {
    "scenarios": [
      "features/db-migration.feature:Schema v2"
    ]
  },
  "pass2": {
    "scenarios": [
      "features/api.feature:List with v2 schema",
      "features/api.feature:Create with v2 schema"
    ]
  }
}
```

## Validation

QM validates `cycle.json` against the schema on startup. If invalid (wrong keys, freeform fields, malformed refs), QM refuses and reports the schema violation to Captain.

This structural validation prevents context leaks — Captain cannot accidentally include chat context or prose worklists.

## Lifecycle

| Action | Who |
|---|---|
| Create / update | Captain |
| Validate | QM (on startup) |
| Read for worklist | QM |
| Read for completion check | Bosun |
| Delete (when cycle done) | Captain, reminded by Bosun |

Bosun does not auto-delete `cycle.json`. Only Captain decides when a directed cycle is complete.

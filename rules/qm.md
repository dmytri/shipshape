---
name: qm
description: Quartermaster fresh-context verification and dispatch.
---

QM custody and verification checklist before returning:

- Verify from durable repository artifacts only
- Run the `discover` and `focused` commands; prefer focused runs, and use `broad` only as a boundary check
- Dispatch work to Crew only; never dispatch production changes to other roles
- For each dispatch, document the target, rationale, and expected failure
- Show the target red before dispatch

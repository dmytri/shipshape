---
name: crew
description: Crew Mate production change for one failing verification target.
---

Crew custody and verification checklist before returning:

- Write production code only; never modify verification support or `.feature` specs
- Annotate every introduced seam with `@planks("<exact step from spec>")`
- Run the `focused` command on your target; show the result
- Show your target passes with no `@logic` regression
- Show no new violations introduced by your change

---
name: shipshape
description: Shipshape Articles of Agreement — context isolation, verification, and durable specs.
---

All roles — before every role transition — verify:

- Context clears at the Captain-to-QM boundary; other transitions use isolated subagents that carry no Captain content
- Every production seam is annotated with `@planks("<step>")`; dead code without annotation is harbour work
- Verification is harmless by design: no side effects, no state leakage, safe to run in parallel
- Fast by design: verify in tiers (`@logic` first, `@sandbox` second); fast feedback loops
- Durable artifacts (specs, watchbill, RIGGING, assets) outrank chat and notes; they are the voyage record

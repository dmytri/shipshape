---
name: boatswain
description: Boatswain hygiene, verification recheck, and local commit custody.
---

Boatswain custody and verification checklist before committing:

- Make hygiene edits and local commits only; never author new behaviour
- Run the verify suite after hygiene edits as a commit boundary check; show all green
- Scan for stale planks (dead code with @planks annotations); remove them
- Scan for forbidden doubles; show any justified `@exceptional-double` tags
- Commit only after all verify results are green and in local history
- Show commit message and changed files before return

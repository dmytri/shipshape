---
description: Run a Crew Mate against one failing verification target
argument-hint: <test, scenario, or failing target>
---

You are a Crew Mate for this project.

Your task: make this failing verification target pass:

$ARGUMENTS

Opening checklist:

1. Confirm `$ARGUMENTS` names exactly one failing target.
2. Read project instructions, relevant specs, tests, fixtures, harness code, and referenced `assets/**`.
3. State the durable artifacts that define expected behavior.
4. Confirm the planned change is limited to minimal production code for this target.

Rules:

- Read `AGENTS.md` or equivalent project instructions.
- Read the relevant Gherkin feature files and tests before changing code.
- Use committed Gherkin feature files and tests as the source of product behavior.
- Implement the minimal production change needed.
- Do not change specs, acceptance criteria, or test intent.
- Do not broaden scope or refactor unrelated code.
- If blocked or uncertain, stop and report the blocker using `templates/blocker-report.md`.

Run the focused target and broader verification where practical. End with target addressed, durable artifacts used, files changed, verification results, and any blocker report.

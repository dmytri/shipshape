# Golden Path Example

This example shows the smallest complete Shipshape loop. The filenames are illustrative; use the directories configured in the target project's `AGENTS.md`.

## 0. Project is configured

The target project has durable workflow configuration:

```text
AGENTS.md
HANDOVER.md                    # optional but recommended
features/                      # <spec directory>
tests/                         # <test directory>
src/                           # <implementation directory>
assets/                        # Captain/human-authored inputs, optional
```

`AGENTS.md` defines commands such as:

```text
<verification discovery command>: npm run test:bdd -- --dry-run
<test command>: npm test
<focused test command>: npm test -- <target>
<typecheck command>: npm run typecheck
```

## 1. Human starts with Captain

Human prompt:

```text
/captain Add password reset. Users should request a reset link by email and then choose a new password from that link.
```

Captain does human-facing discovery and writes durable behavior, for example:

```gherkin
Feature: Password reset
  Registered users can reset a forgotten password using an email link.

  Scenario: Requesting a reset link for a registered email
    Given a registered user exists with email "sam@example.com"
    When the user requests a password reset for "sam@example.com"
    Then a password reset email is queued for "sam@example.com"
    And the reset link expires in 30 minutes

  Scenario: Resetting the password with a valid link
    Given a registered user has requested a password reset
    When the user opens the reset link and submits a new valid password
    Then the user's password is changed
    And the reset link cannot be used again
```

Captain may also update `AGENTS.md`, `HANDOVER.md`, or approved files under `assets/**` if the specs reference durable content or design inputs.

Captain final instruction:

```text
Specs have been updated. Clear this session or start a new agent session before invoking /qm so Quartermaster cannot see this discovery chat.
```

## 2. User clears context, then runs Quartermaster

After clearing or opening a fresh session:

```text
/qm password reset
```

Quartermaster first performs the context-firewall check. If the session is clean, it reads only durable artifacts:

```text
AGENTS.md
HANDOVER.md
features/password-reset.feature
tests/**
assets/** referenced by specs
```

Quartermaster writes missing executable coverage, for example:

```text
tests/bdd/password-reset.steps.ts
tests/password-reset.test.ts
```

Quartermaster runs verification and finds a failing implementation target:

```text
Failing target: tests/password-reset.test.ts > resetting the password with a valid link
```

Quartermaster dispatches Crew with routing context only:

```text
/crew Make the failing verification target pass: tests/password-reset.test.ts > resetting the password with a valid link
Read the committed specs and tests for behavior. Do not change specs or test intent.
```

## 3. Crew implements one target

Crew reads:

```text
AGENTS.md
features/password-reset.feature
tests/password-reset.test.ts
related production files under src/
```

Crew changes only the minimal production code needed for that target, then runs focused verification:

```text
npm test -- tests/password-reset.test.ts
```

Crew final report includes:

```text
Target addressed: tests/password-reset.test.ts > resetting the password with a valid link
Files changed: src/auth/password-reset.ts
Verification: focused target passed
Remaining failures: request-link scenario still failing; not part of this Crew target
```

## 4. Quartermaster repeats or verifies broadly

Quartermaster reruns the relevant suite, dispatches another Crew target if needed, or records green status.

```text
/qm password reset
```

QM final report includes coverage changed, commands run, Crew targets dispatched, and remaining blockers or failures.

## 5. Blocker path returns to Captain

If QM or Crew finds missing/contradictory behavior, it does not guess. It writes a blocker report using `templates/blocker-report.md`:

```md
# Blocker Report

## Reporting Role
`Quartermaster`

## Target
`features/password-reset.feature / reset link expiration`

## Blocker Type
- [x] Missing normative requirement

## What I Read
- `features/password-reset.feature`
- `AGENTS.md`

## What I Tried
- `npm run test:bdd -- --dry-run`

## Exact Blocker
The spec says the reset link expires in 30 minutes, but does not say whether an expired link should show a generic error, offer to resend, or redirect to login.

## Why I Cannot Continue
Any test expectation here would encode product behavior that is not present in durable specs.

## Suggested Captain Resolution
Add acceptance criteria for expired reset links.
```

Then the user invokes Captain from that QM/Crew blocker context:

```text
/captain Resolve the password reset expired-link blocker.
```

Do not clear before this Captain escalation unless there is another reason to. Captain benefits from the concrete failure evidence, updates durable specs/instructions, then the user clears again before returning to Quartermaster.

# Golden Path Example

This example shows the smallest complete Shipshape loop. The filenames are illustrative; use the directories configured in the target project's `AGENTS.md`.

The handoff is the product: Captain writes durable intent, QM reads only repo artifacts, Crew starts from failing verification, and Bosun leaves a clean local commit boundary.

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

Captain does human-facing discovery and writes durable behavior as valid Gherkin, for example:

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

Quartermaster first performs the context-firewall check. If the session is clean, it reads only durable artifacts. If it needs hidden chat context, Captain failed.

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
Read the durable specs and source-controlled tests for behavior. Do not change specs or test intent.
```

## 3. Crew implements one target

Crew reads:

```text
AGENTS.md
features/password-reset.feature
tests/password-reset.test.ts
related production files under src/
```

Crew starts from the failing verification target, not inherited chat context. Crew changes only the minimal production code needed for that target, then runs focused verification:

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

QM final report includes coverage changed, commands run, Crew targets dispatched, Bosun handoff/fallback status, and remaining blockers or failures.

After Crew Mate reports verification passing, QM hands off to Bosun. In harnesses that support subagents, separate role sessions, or skill invocation, QM must dispatch or request:

```text
/bosun password reset completed
```

Only in harnesses that cannot spawn or invoke a separate Bosun role, such as Pi, may QM assume Bosun duties directly. In that fallback, QM reports:

```text
No Bosun subagent/role handoff is available in this harness; QM assumed Bosun duties as the required fallback.
```

## 5. Bosun leaves the deck clean

Bosun runs after Crew passes and before the next Captain voyage:

```text
/bosun password reset completed
```

Bosun checks:

```text
git status
git diff
unused BDD steps
obsolete fixtures/helpers
stale snapshots or visual baselines
stale assets related to removed scenarios
dead implementation paths
generated/temp files
dependency/config drift
HANDOVER.md stale notes
```

Bosun may remove stale artifacts, rerun checks, stage intended changes only, and create a local commit:

```text
git add <intended files>
git commit -m "Implement password reset"
```

Bosun final report includes verification results, commit hash/message, clean working tree status, and explicit confirmation that nothing was pushed, tagged, published, or released.

Bosun leaves the deck clean and the work committed, but does not send the ship out.

## 6. Captain offers outbound next steps

After Bosun reports completed work, a local commit, passing verification, and a clean deck, Captain summarizes the work and offers human-approved outbound next steps:

```text
/captain password reset is clean and committed; decide whether to push, open a PR, release, publish, or deploy
```

Captain may offer actions such as pushing the branch, opening a PR, tagging/releasing, publishing a package, deploying, or handing off to a release/deploy system. Captain performs an outbound action only when the human explicitly approves it and project instructions allow it.

The next Captain starts from a clean deck.

## 7. Blocker path returns to Captain

If QM, Crew, or Bosun finds missing/contradictory behavior, it does not guess. It writes a blocker report using `templates/blocker-report.md`:

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

Bosun stops at the local commit boundary: it does not push, tag, publish, or release.

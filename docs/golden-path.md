# Golden Path Example

This example shows the smallest complete Shipshape loop. Filenames are illustrative; use the directories configured in the target project's `AGENTS.md`.

The key invariant: **only Captain → QM requires a cleared/fresh context**. After QM starts clean, QM, Crew, Bosun, and Captain transition by loading the next role skill because their context is grounded in durable repo artifacts and verification output.

## 0. Project is configured

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

Captain ends with the only mandatory context-reset instruction:

```text
Specs have been updated. Clear this session or start a fresh session before invoking /qm so Quartermaster cannot see this discovery chat.
```

## 2. User clears context, then runs Quartermaster

After clearing or opening a fresh session:

```text
/qm password reset
```

Quartermaster performs the context-firewall check. If clean, it reads only durable artifacts:

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

## 3. QM loads Crew for one target

Quartermaster loads `crew/SKILL.md` and becomes Crew for the failing target, or dispatches Crew if the harness provides subagents.

Crew reads:

```text
AGENTS.md
features/password-reset.feature
tests/password-reset.test.ts
related production files under src/
```

Crew changes only the production code needed for that target, then runs focused verification:

```text
npm test -- tests/password-reset.test.ts
```

Crew result:

```text
Target addressed: tests/password-reset.test.ts > resetting the password with a valid link
Files changed: src/auth/password-reset.ts
Verification: focused target passed
```

When the target passes, Crew loads `qm/SKILL.md` and becomes Quartermaster again, or reports back to QM if running as a subagent.

## 4. QM verifies and loads Bosun

Quartermaster reruns relevant verification. If more implementation targets fail, QM loads Crew for the next target. When implementation verification passes, QM loads `bosun/SKILL.md` and becomes Bosun.

## 5. Bosun leaves the deck clean

Bosun checks changed-file-adjacent hygiene:

```text
git status
git diff
unused or obsolete BDD steps
obsolete fixtures/helpers
stale snapshots or generated files
stale HANDOVER.md notes
configured verification commands
```

Bosun may remove stale artifacts, rerun checks, stage intended changes only, and create a local commit:

```text
git add <intended files>
git commit -m "Implement password reset"
```

Bosun result:

```text
Verification: passed
Commit: abc123 Implement password reset
Deck: clean
```

When the deck is clean, Bosun loads `captain/SKILL.md` and becomes Captain.

## 6. Captain offers outbound next steps

Captain summarizes the completed work and offers human-approved outbound next steps:

```text
Password reset is clean and committed as abc123. Would you like me to push the branch, open a PR, publish/release, deploy, or leave it local?
```

Captain performs outbound actions only when the human explicitly approves them and project instructions allow them.

## 7. Blocker path returns to Captain

If QM, Crew, or Bosun finds missing or contradictory product intent, it loads Captain with concrete blocker context instead of guessing.

Example blocker:

```md
# Blocker Report

## Reporting Role
`Quartermaster`

## Target
`features/password-reset.feature / reset link expiration`

## Exact Blocker
The spec says the reset link expires in 30 minutes, but does not say whether an expired link should show a generic error, offer to resend, or redirect to login.

## Why I Cannot Continue
Any test expectation here would encode product behavior that is not present in durable specs.

## Suggested Captain Resolution
Add acceptance criteria for expired reset links.
```

Captain updates durable specs/instructions using the blocker evidence. After Captain resolves product/spec intent, the user clears again before returning to QM.

#!/bin/sh
# Shipshape hook tests. Run: sh tests/hooks.sh
# Exercises the custody and guard scripts against fixture payloads.
# Exits nonzero on any failure.

set -u

repo=$(cd "$(dirname "$0")/.." && pwd)
scripts="$repo/hooks/scripts"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/proj/src" "$work/proj/features/steps" "$work/proj/scantlings"
printf 'plain user session, no marker\n' > "$work/t-main.jsonl"
printf 'earlier: Launching skill: captain\n' > "$work/t-dirty.jsonl"
cat > "$work/proj/RIGGING.md" <<'RIG'
## Stack

- language: typescript

## Directories

- implementation: src/
- specs: features/
- verification: features/steps/
- verification: features/support/
- assets: assets/
- scantlings: scantlings/

## Commands

- focused: `run {scenario}`

## Perturbation

- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`
RIG

mkdir -p "$work/mono/packages/shim/src" "$work/mono/packages/shim/features/steps"
cat > "$work/mono/RIGGING.md" <<'RIG'
## Directories

- implementation: src
- implementation: packages/*/src
- specs: features
- specs: packages/*/features
- verification: features/steps
- verification: packages/*/features/steps
- assets: assets
- assets: packages/*/assets
RIG

# Cucumber-conventional layout: step definitions live under the specs
# directory, so the verification value contains it. Artifact kind decides
# custody of a .feature file, never the directory it sits in.
mkdir -p "$work/cuke/src" "$work/cuke/features/step_definitions"
cat > "$work/cuke/RIGGING.md" <<'RIG'
## Directories

- implementation: src
- specs: features
- verification: features
RIG

pass=0
fail=0

check() {
  name="$1" script="$2" payload="$3" want="$4"
  printf '%s' "$payload" | "$scripts/$script" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL: $name: want exit $want, got $got"
  fi
}

p() {
  printf '{"agent_type":"%s","cwd":"%s","tool_input":{"file_path":"%s"}}' "$1" "$work/proj" "$2"
}
b() {
  printf '{"agent_type":"%s","cwd":"%s","tool_input":{"command":"%s"}}' "$1" "$work/proj" "$2"
}
pm() {
  printf '{"agent_type":"%s","cwd":"%s","tool_input":{"file_path":"%s"}}' "$1" "$work/mono" "$2"
}
pc() {
  printf '{"agent_type":"%s","cwd":"%s","tool_input":{"file_path":"%s"}}' "$1" "$work/cuke" "$2"
}

# write-custody
check "crew blocked from specs" write-custody.sh "$(p "shipshape:crew" "$work/proj/features/pay.feature")" 2
check "crew allowed in src" write-custody.sh "$(p "shipshape:crew" "$work/proj/src/pay.ts")" 0
check "crew blocked from step defs" write-custody.sh "$(p "shipshape:crew" "$work/proj/features/steps/pay.steps.ts")" 2
check "crew blocked from RIGGING.md" write-custody.sh "$(p "shipshape:crew" "$work/proj/RIGGING.md")" 2
check "qm blocked from src" write-custody.sh "$(p "shipshape:qm" "$work/proj/src/pay.ts")" 2
check "qm allowed in step defs" write-custody.sh "$(p "shipshape:qm" "$work/proj/features/steps/pay.steps.ts")" 0
check "qm blocked from specs" write-custody.sh "$(p "shipshape:qm" "$work/proj/features/pay.feature")" 2
check "boatswain blocked from CAPTAIN.md" write-custody.sh "$(p "shipshape:boatswain" "$work/proj/CAPTAIN.md")" 2
check "boatswain allowed hygiene edits" write-custody.sh "$(p "shipshape:boatswain" "$work/proj/src/pay.ts")" 0
check "captain allowed to write a spec" write-custody.sh "$(p "shipshape:captain" "$work/proj/features/pay.feature")" 0
check "captain blocked from step defs" write-custody.sh "$(p "shipshape:captain" "$work/proj/features/steps/pay.steps.ts")" 2
check "shipwright allowed to write a skeleton" write-custody.sh "$(p "shipshape:shipwright" "$work/proj/features/pay.feature")" 0
check "shipwright blocked from step defs" write-custody.sh "$(p "shipshape:shipwright" "$work/proj/features/steps/pay.steps.ts")" 2
check "crew blocked from scantlings" write-custody.sh "$(p "shipshape:crew" "$work/proj/scantlings/orders.openapi.yaml")" 2
check "qm blocked from scantlings" write-custody.sh "$(p "shipshape:qm" "$work/proj/scantlings/orders.openapi.yaml")" 2
check "shipwright blocked from scantlings" write-custody.sh "$(p "shipshape:shipwright" "$work/proj/scantlings/orders.openapi.yaml")" 2
check "foreign agent unrestricted" write-custody.sh "$(p "Explore" "$work/proj/features/pay.feature")" 0
check "main loop unrestricted" write-custody.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"file_path\":\"$work/proj/features/pay.feature\"}}" 0
check "quoted agent_type cannot match" write-custody.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"file_path\":\"$work/proj/features/pay.feature\",\"content\":\"mentions \\\"agent_type\\\": \\\"shipshape:crew\\\"\"}}" 0

# write-custody: monorepo glob directories, one path per line, * is one path segment
check "crew allowed in package src (glob)" write-custody.sh "$(pm "shipshape:crew" "$work/mono/packages/shim/src/x.ts")" 0
check "crew blocked from package spec (glob)" write-custody.sh "$(pm "shipshape:crew" "$work/mono/packages/shim/features/x.feature")" 2
check "crew blocked from package step defs (glob)" write-custody.sh "$(pm "shipshape:crew" "$work/mono/packages/shim/features/steps/x.ts")" 2
check "qm blocked from package src (glob)" write-custody.sh "$(pm "shipshape:qm" "$work/mono/packages/shim/src/x.ts")" 2

# write-custody: Cucumber-conventional layout, verification directory contains
# the specs directory. Artifact kind decides a .feature, not the directory.
check "captain allowed to write a spec under a Cucumber layout" write-custody.sh "$(pc "shipshape:captain" "$work/cuke/features/pay.feature")" 0
check "shipwright allowed to write a skeleton under a Cucumber layout" write-custody.sh "$(pc "shipshape:shipwright" "$work/cuke/features/pay.feature")" 0
check "captain still blocked from step defs under a Cucumber layout" write-custody.sh "$(pc "shipshape:captain" "$work/cuke/features/step_definitions/pay.steps.ts")" 2
check "crew still blocked from a spec under a Cucumber layout" write-custody.sh "$(pc "shipshape:crew" "$work/cuke/features/pay.feature")" 2
check "qm still blocked from a spec under a Cucumber layout" write-custody.sh "$(pc "shipshape:qm" "$work/cuke/features/pay.feature")" 2

# bash-custody
check "crew blocked from git commit" bash-custody.sh "$(b "shipshape:crew" "git commit -m x")" 2
check "boatswain allowed git commit" bash-custody.sh "$(b "shipshape:boatswain" "git commit -m x")" 0
check "boatswain blocked from git push" bash-custody.sh "$(b "shipshape:boatswain" "git push origin main")" 2
check "qm blocked from publish" bash-custody.sh "$(b "shipshape:qm" "npm publish")" 2
check "foreign agent push unrestricted" bash-custody.sh "$(b "Explore" "git push origin main")" 0
check "main loop push unrestricted" bash-custody.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"git push origin main\"}}" 0

# captain-notes-guard
check "qm blocked from reading CAPTAIN.md" captain-notes-guard.sh "$(p "shipshape:qm" "$work/proj/CAPTAIN.md")" 2
check "crew blocked from grepping CAPTAIN.md" captain-notes-guard.sh "$(p "shipshape:crew" "$work/proj/CAPTAIN.md")" 2
check "boatswain blocked from reading CAPTAIN.md" captain-notes-guard.sh "$(p "shipshape:boatswain" "$work/proj/CAPTAIN.md")" 2
check "foreign agent reads unrestricted" captain-notes-guard.sh "$(p "Explore" "$work/proj/CAPTAIN.md")" 0
check "main loop reads unrestricted" captain-notes-guard.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"file_path\":\"$work/proj/CAPTAIN.md\"}}" 0
check "qm other reads unaffected" captain-notes-guard.sh "$(p "shipshape:qm" "$work/proj/features/pay.feature")" 0
check "crew blocked from cat CAPTAIN.md" bash-custody.sh "$(b "shipshape:crew" "cat CAPTAIN.md")" 2
check "boatswain blocked from cat CAPTAIN.md" bash-custody.sh "$(b "shipshape:boatswain" "cat CAPTAIN.md")" 2
check "boatswain allowed staging CAPTAIN.md by path" bash-custody.sh "$(b "shipshape:boatswain" "git add -- CAPTAIN.md")" 0
check "boatswain allowed :!CAPTAIN.md exclusion" bash-custody.sh "$(b "shipshape:boatswain" "git diff c5cad19 -- . ':!CAPTAIN.md'")" 0
check "boatswain add-then-cat still blocked" bash-custody.sh "$(b "shipshape:boatswain" "git add -- CAPTAIN.md && cat CAPTAIN.md")" 2
check "qm blocked from staging CAPTAIN.md" bash-custody.sh "$(b "shipshape:qm" "git add -- CAPTAIN.md")" 2
check "boatswain quoted label mention allowed" bash-custody.sh "$(b "shipshape:boatswain" "echo \\\"--- has CAPTAIN.md? ---\\\" && git status")" 0
check "boatswain commit message naming notes allowed" bash-custody.sh "$(b "shipshape:boatswain" "git commit -m 'voyage custody; Captain notes CAPTAIN.md staged content-blind'")" 0
check "boatswain metadata stat allowed" bash-custody.sh "$(b "shipshape:boatswain" "ls -la CAPTAIN.md 2>&1")" 0
check "boatswain -C staging form allowed" bash-custody.sh "$(b "shipshape:boatswain" "git -C /tmp/proj add -- CAPTAIN.md")" 0
check "boatswain multi-path staging allowed" bash-custody.sh "$(b "shipshape:boatswain" "git add -- src/pay.js features/pay.feature CAPTAIN.md")" 0
check "boatswain multi-path staging with flags allowed" bash-custody.sh "$(b "shipshape:boatswain" "git -C /tmp/proj add -A -- src CAPTAIN.md")" 0
check "boatswain multi-path staging then read blocked" bash-custody.sh "$(b "shipshape:boatswain" "git add -- src CAPTAIN.md ; cat CAPTAIN.md")" 2
check "boatswain multi-path staging then pipe read blocked" bash-custody.sh "$(b "shipshape:boatswain" "git add -- src CAPTAIN.md | grep -c . CAPTAIN.md")" 2
check "qm multi-path staging blocked" bash-custody.sh "$(b "shipshape:qm" "git add -- src CAPTAIN.md")" 2
check "boatswain quoted lone path still read-blocked" bash-custody.sh "$(b "shipshape:boatswain" "cat 'CAPTAIN.md'")" 2
check "boatswain removal blocked" bash-custody.sh "$(b "shipshape:boatswain" "rm CAPTAIN.md")" 2
check "crew quoted mention allowed" bash-custody.sh "$(b "shipshape:crew" "echo \\\"CAPTAIN.md is Captain-only\\\"")" 0
check "crew redirect into notes blocked" bash-custody.sh "$(b "shipshape:crew" "echo note >> CAPTAIN.md")" 2
check "captain allowed notes-only commit" bash-custody.sh "$(b "shipshape:captain" "git commit -m notes -- CAPTAIN.md")" 0
check "captain blocked from general commit" bash-custody.sh "$(b "shipshape:captain" "git commit -m x")" 2
check "captain notes commit cannot ride a push" bash-custody.sh "$(b "shipshape:captain" "git commit -m notes -- CAPTAIN.md && git push")" 2

# Initial commit: an unborn HEAD is Captain's own bootstrap action
# (skills/captain/SKILL.md); a born HEAD keeps Boatswain custody, and
# a cwd outside any work tree keeps the deny.
git init -q "$work/unborn"
git init -q "$work/born"
git -C "$work/born" -c user.email=t@t.test -c user.name=t commit -q --allow-empty -m init
bg() {
  printf '{"agent_type":"%s","cwd":"%s","tool_input":{"command":"%s"}}' "$1" "$2" "$3"
}
check "captain allowed initial commit on unborn HEAD" bash-custody.sh "$(bg "shipshape:captain" "$work/unborn" "git commit -m 'initial state'")" 0
check "captain blocked from general commit on born HEAD" bash-custody.sh "$(bg "shipshape:captain" "$work/born" "git commit -m x")" 2
check "crew still blocked from commit on unborn HEAD" bash-custody.sh "$(bg "shipshape:crew" "$work/unborn" "git commit -m x")" 2
check "captain initial commit cannot ride a push" bash-custody.sh "$(bg "shipshape:captain" "$work/unborn" "git commit -m init && git push")" 2
check "qm blocked from reading transcript" bash-custody.sh "{\"agent_type\":\"shipshape:qm\",\"transcript_path\":\"$work/t-dirty.jsonl\",\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"cat $work/t-dirty.jsonl\"}}" 2
check "qm benign command allowed" bash-custody.sh "{\"agent_type\":\"shipshape:qm\",\"transcript_path\":\"$work/t-dirty.jsonl\",\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"ls src\"}}" 0
check "boatswain blocked from transcript" bash-custody.sh "{\"agent_type\":\"shipshape:boatswain\",\"transcript_path\":\"$work/t-dirty.jsonl\",\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"cat $work/t-dirty.jsonl\"}}" 2

# captain-reset-nudge (PostToolUse; nudge fires on stdout, blocks nothing)
nudge() {
  name="$1" payload="$2" want="$3"
  out=$(printf '%s' "$payload" | "$scripts/captain-reset-nudge.sh" 2>/dev/null)
  case "$out" in
    *"Batch shipped"*) got="fire" ;;
    *) got="silent" ;;
  esac
  if [ "$got" = "$want" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL: $name: want $want, got $got"
  fi
}
nudge "captain outbound push nudged" "{\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"git push origin main\"}}" "fire"
nudge "captain publish nudged" "{\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"npm publish --access public\"}}" "fire"
nudge "captain non-outbound silent" "{\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"git status\"}}" "silent"
nudge "internal role push not nudged" "$(b "shipshape:qm" "git push origin main")" "silent"

# feature-quality
printf 'Feature: Pay\n\n  Scenario: Pays\n    Given a card\n    When paying\n    Then paid\n' > "$work/proj/features/good.feature"
printf 'Scenario: floating scenario with no steps\n' > "$work/proj/features/bad.feature"
printf 'Feature: Pay\n\n  # workaround for the flaky gateway, remove when fixed\n  Scenario: Pays\n    Given a card\n    When paying\n    Then paid\n' > "$work/proj/features/commented.feature"
check "well-formed feature passes" feature-quality.sh "$(p "Explore" "$work/proj/features/good.feature")" 0
check "malformed feature blocked" feature-quality.sh "$(p "Explore" "$work/proj/features/bad.feature")" 2
check "commented feature blocked" feature-quality.sh "$(p "Explore" "$work/proj/features/commented.feature")" 2
check "non-feature files ignored" feature-quality.sh "$(p "Explore" "$work/proj/src/pay.ts")" 0

# rigging-validate
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$scripts/rigging-validate.sh")
if [ -z "$out" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: complete RIGGING.md is silent"; fi
grep -v 'perturb' "$work/proj/RIGGING.md" > "$work/proj/RIGGING.tmp" && mv "$work/proj/RIGGING.tmp" "$work/proj/RIGGING.md"
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$scripts/rigging-validate.sh")
case "$out" in
  *perturb*) pass=$((pass + 1)) ;;
  *) fail=$((fail + 1)); echo "FAIL: missing perturb is reported" ;;
esac

# update-nudge (SessionStart; nudge fires on stdout, blocks nothing)
unudge() {
  name="$1" remote_ver="$2" want="$3"
  printf '{"version": "%s"}\n' "$remote_ver" > "$work/remote.json"
  out=$(SHIPSHAPE_REMOTE_MANIFEST="$work/remote.json" "$scripts/update-nudge.sh" 2>/dev/null)
  case "$out" in
    *"available"*) got="fire" ;;
    *) got="silent" ;;
  esac
  if [ "$got" = "$want" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL: $name: want $want, got $got"
  fi
}
installed_ver=$(sed -n 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$repo/.plugin/plugin.json" | head -n1)
unudge "newer remote nudges" "99.0.0" "fire"
unudge "same version silent" "$installed_ver" "silent"
unudge "older remote silent" "0.0.1" "silent"
# missing remote manifest stays silent
out=$(SHIPSHAPE_REMOTE_MANIFEST="$work/absent.json" "$scripts/update-nudge.sh" 2>/dev/null)
case "$out" in "") pass=$((pass + 1)) ;; *) fail=$((fail + 1)); echo "FAIL: missing remote manifest stays silent" ;; esac

# planks-check
cd "$work/proj" && git init -q . && git add -A && git -c user.email=t@t -c user.name=t commit -qm init
cat >> "$work/proj/RIGGING.md" <<'RIG'
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`
RIG
printf 'export function pay() {}\n' > "$work/proj/src/unplanked.ts"
git add -A
check "unplanked change blocked for crew" planks-check.sh "{\"agent_type\":\"shipshape:crew\",\"cwd\":\"$work/proj\"}" 2
printf '/**\n * @planks("When paying")\n */\nexport function pay() {}\n' > "$work/proj/src/unplanked.ts"
check "planked change passes for crew" planks-check.sh "{\"agent_type\":\"shipshape:crew\",\"cwd\":\"$work/proj\"}" 0
check "main loop planks unrestricted" planks-check.sh "{\"cwd\":\"$work/proj\"}" 0

# dispatch-guard
filler=$(i=0; s=""; while [ $i -lt 60 ]; do s="${s}0123456789012345678901234567890123456789012345678"; i=$((i+1)); done; printf '%s' "$s")
check "captain thin dispatch allowed" dispatch-guard.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"subagent_type\":\"shipshape:qm\",\"prompt\":\"Role: qm. Base: abc123. Watchbill: watchbill.json.\"}}" 0
check "captain fat dispatch blocked" dispatch-guard.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"subagent_type\":\"shipshape:qm\",\"prompt\":\"$filler\"}}" 2
check "sentinel dispatch blocked" dispatch-guard.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"subagent_type\":\"shipshape:crew\",\"prompt\":\"notes say STOP. Captain's notes: non-binding\"}}" 2
check "qm evidence dispatch exempt from cap" dispatch-guard.sh "{\"agent_type\":\"shipshape:qm\",\"cwd\":\"$work/proj\",\"tool_input\":{\"subagent_type\":\"shipshape:crew\",\"prompt\":\"$filler\"}}" 0
check "foreign target ignored" dispatch-guard.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"subagent_type\":\"Explore\",\"prompt\":\"$filler\"}}" 0

# --- regression tests for audit fixes ---

# write-custody covers NotebookEdit (notebook_path), not only file_path.
check "qm blocked from src notebook" write-custody.sh "{\"agent_type\":\"shipshape:qm\",\"cwd\":\"$work/proj\",\"tool_input\":{\"notebook_path\":\"$work/proj/src/pay.ipynb\"}}" 2
check "main loop notebook unrestricted" write-custody.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"notebook_path\":\"$work/proj/src/pay.ipynb\"}}" 0

# bash-custody catches git global flags before the subcommand, and reads
# only the command field so a mention elsewhere does not trigger custody.
check "boatswain blocked from git -C push" bash-custody.sh "$(b "shipshape:boatswain" "git -C /x push origin main")" 2
check "push in description does not trigger custody" bash-custody.sh "{\"agent_type\":\"shipshape:qm\",\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"ls src\",\"description\":\"prepare to git push later\"}}" 0

# bash-custody survives escaped quotes and chained commands, and resolves
# the true git subcommand instead of substring-matching.
check "quoted arg cannot hide a push" bash-custody.sh "$(b "shipshape:crew" "echo \\\"x\\\" && git push origin main")" 2
check "chained second git push blocked" bash-custody.sh "$(b "shipshape:crew" "git status && git push origin main")" 2
check "quoted commit message still commits for boatswain" bash-custody.sh "$(b "shipshape:boatswain" "git commit -m \\\"fix: pay\\\"")" 0
check "git stash push stays open" bash-custody.sh "$(b "shipshape:crew" "git stash push")" 0
check "git log --grep push stays open" bash-custody.sh "$(b "shipshape:crew" "git log --grep push")" 0
check "git tag -l stays open" bash-custody.sh "$(b "shipshape:boatswain" "git tag -l")" 0
check "git tag creation still blocked" bash-custody.sh "$(b "shipshape:boatswain" "git tag v1.0.0")" 2

# captain-notes-guard blocks a Read of the transcript file itself.
check "qm blocked from reading transcript file" captain-notes-guard.sh "{\"agent_type\":\"shipshape:qm\",\"transcript_path\":\"$work/t-dirty.jsonl\",\"cwd\":\"$work/proj\",\"tool_input\":{\"file_path\":\"$work/t-dirty.jsonl\"}}" 2
check "boatswain blocked from transcript file" captain-notes-guard.sh "{\"agent_type\":\"shipshape:boatswain\",\"transcript_path\":\"$work/t-dirty.jsonl\",\"cwd\":\"$work/proj\",\"tool_input\":{\"file_path\":\"$work/t-dirty.jsonl\"}}" 2

# reset-nudge reads only the command, not the tool output.
nudge "push in tool output does not fire nudge" "{\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"git status\"},\"tool_response\":{\"stdout\":\"use git push to publish\"}}" "silent"

# planks-check flags an untracked new production file.
printf 'export function extra() {}\n' > "$work/proj/src/untracked.ts"
check "untracked unplanked file blocked for crew" planks-check.sh "{\"agent_type\":\"shipshape:crew\",\"cwd\":\"$work/proj\"}" 2

# --- regression tests for custody hardening ---

# bash-custody resolves a path-prefixed git binary, a command git form,
# and a shell -c string; a quoted echo argument stays innocent.
check "path-prefixed git push blocked" bash-custody.sh "$(b "shipshape:crew" "/usr/bin/git push origin main")" 2
check "command git push blocked" bash-custody.sh "$(b "shipshape:boatswain" "command git push origin main")" 2
check "sh -c git push blocked" bash-custody.sh "$(b "shipshape:crew" "sh -c \\\"git push origin main\\\"")" 2
check "quoted echo git push stays open" bash-custody.sh "$(b "shipshape:crew" "echo \\\"git push\\\"")" 0
check "path-prefixed git status stays open" bash-custody.sh "$(b "shipshape:crew" "/usr/bin/git status")" 0

# write-custody normalizes . and .. segments before directory matching.
check "crew traversal into specs blocked" write-custody.sh "$(p "shipshape:crew" "$work/proj/src/../features/notes.txt")" 2
check "qm traversal into src blocked" write-custody.sh "$(p "shipshape:qm" "$work/proj/features/steps/../../src/pay.ts")" 2
check "dotdot absolute path into src blocked" write-custody.sh "$(p "shipshape:qm" "/x/..$work/proj/src/pay.ts")" 2
check "clean path still allowed after normalize" write-custody.sh "$(p "shipshape:crew" "$work/proj/src/pay.ts")" 0

# write-custody captain branch: verification denied, specs and the
# perturbation seam stay open.
check "captain blocked from step defs" write-custody.sh "$(p "shipshape:captain" "$work/proj/features/steps/pay.steps.ts")" 2
check "captain allowed to write specs" write-custody.sh "$(p "shipshape:captain" "$work/proj/features/pay.feature")" 0
check "captain src write stays open for perturbation" write-custody.sh "$(p "shipshape:captain" "$work/proj/src/pay.ts")" 0

# dispatch-guard: the cap binds the Captain seat including a spawned
# Captain, and measures the prompt, not the payload.
check "spawned captain fat dispatch blocked" dispatch-guard.sh "{\"agent_type\":\"shipshape:captain\",\"cwd\":\"$work/proj\",\"tool_input\":{\"subagent_type\":\"shipshape:qm\",\"prompt\":\"$filler\"}}" 2
check "spawned captain thin dispatch allowed" dispatch-guard.sh "{\"agent_type\":\"shipshape:captain\",\"cwd\":\"$work/proj\",\"tool_input\":{\"subagent_type\":\"shipshape:qm\",\"prompt\":\"Role: qm. Base: abc123.\"}}" 0
check "long payload with thin prompt allowed" dispatch-guard.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"subagent_type\":\"shipshape:qm\",\"prompt\":\"Role: qm. Base: abc123.\",\"description\":\"$filler\"}}" 0

# planks-check scopes to roles that write production code and to added
# seam lines, skipping non-code files and operator-style edits.
rm "$work/proj/src/untracked.ts"
printf 'export function extra() {}\n' > "$work/proj/src/seam.ts"
check "qm stop unaffected by unplanked seam" planks-check.sh "{\"agent_type\":\"shipshape:qm\",\"cwd\":\"$work/proj\"}" 0
check "boatswain stop unaffected by unplanked seam" planks-check.sh "{\"agent_type\":\"shipshape:boatswain\",\"cwd\":\"$work/proj\"}" 0
check "crew still blocked by added unplanked seam" planks-check.sh "{\"agent_type\":\"shipshape:crew\",\"cwd\":\"$work/proj\"}" 2
rm "$work/proj/src/seam.ts"
printf '{"map": "x => y"}\n' > "$work/proj/src/config.json"
check "operator json edit in impl ignored" planks-check.sh "{\"agent_type\":\"shipshape:crew\",\"cwd\":\"$work/proj\"}" 0
rm "$work/proj/src/config.json"
printf 'export const flag = true\n' > "$work/proj/src/notes.ts"
check "non-seam addition ignored" planks-check.sh "{\"agent_type\":\"shipshape:crew\",\"cwd\":\"$work/proj\"}" 0
rm "$work/proj/src/notes.ts"
printf 'export function spaced() {}\n' > "$work/proj/src/pay mate.ts"
check "unplanked seam in spaced path blocked" planks-check.sh "{\"agent_type\":\"shipshape:crew\",\"cwd\":\"$work/proj\"}" 2
rm "$work/proj/src/pay mate.ts"

# feature-quality exempts the language directive and doc-string # lines
# while a bare comment stays blocked, pinned above.
printf '# language: fr\nFeature: Pay\n\n  Scenario: Pays\n    Given a card\n    When paying with:\n      """\n      # raw payload line\n      amount: 5\n      """\n    Then paid\n' > "$work/proj/features/lang.feature"
check "language directive and doc-string hash allowed" feature-quality.sh "$(p "Explore" "$work/proj/features/lang.feature")" 0

# captain-reset-nudge shares the hardened git matcher.
nudge "path-prefixed git push nudged" "{\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"/usr/bin/git push origin main\"}}" "fire"
nudge "git -C push nudged" "{\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"git -C . push origin main\"}}" "fire"
nudge "git stash push not nudged" "{\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"git stash push\"}}" "silent"
nudge "git tag -l not nudged" "{\"cwd\":\"$work/proj\",\"tool_input\":{\"command\":\"git tag -l\"}}" "silent"

# session-orient counts exact tags only: @captain-review is not @captain.
printf '@captain\nFeature: Tagged\n\n  Scenario: A\n    Given x\n    When y\n    Then z\n' > "$work/proj/features/tagged.feature"
printf '@captain-review\nFeature: Reviewed\n\n  Scenario: B\n    Given x\n    When y\n    Then z\n' > "$work/proj/features/reviewed.feature"
git -C "$work/proj" add features/tagged.feature features/reviewed.feature
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$scripts/session-orient.sh")
case "$out" in
  *"@captain scenarios: 1;"*) pass=$((pass + 1)) ;;
  *) fail=$((fail + 1)); echo "FAIL: session-orient counts exact @captain tags" ;;
esac

# background-custody: blocks a stop holding unconsumed backgrounded output,
# and only that. An Agent child is NOT the fault: its report resumes the
# caller, per Hand-off custody, so a turn ending on one self-heals.
bg() {
  name="$1" body="$2" want="$3" sha="${4:-false}" bgt="${5:-[]}"
  printf '%s' "$body" > "$work/bg.jsonl"
  printf '{"agent_type":"shipshape:qm","transcript_path":"%s","agent_transcript_path":"%s","stop_hook_active":%s,"background_tasks":%s}' \
    "$work/session.jsonl" "$work/bg.jsonl" "$sha" "$bgt" \
    | "$scripts/background-custody.sh" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then pass=$((pass + 1)); else
    fail=$((fail + 1)); echo "FAIL: background-custody $name: want $want, got $got"; fi
}

LAUNCH='{"type":"user","message":{"content":[{"type":"tool_result","content":"Command did not complete within its 120s timeout and was moved to the background (ID: bx1). Output is being written to: /t/tasks/bx1.output"}]}}'
READIT='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"/t/tasks/bx1.output"}}]}}'
CATIT='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"cat /t/tasks/bx1.output"}}]}}'
AGENTC='{"type":"user","message":{"content":[{"type":"tool_result","content":"Async agent launched successfully.\nagentId: a99 (internal ID - do not mention to user.)"}]}}'

bg "unconsumed background blocks the stop" "$LAUNCH" 2
bg "output read in-turn passes" "$LAUNCH
$READIT" 0
bg "output cat in-turn passes" "$LAUNCH
$CATIT" 0
bg "live Agent child is not the fault" "$AGENTC" 0
bg "nothing backgrounded passes" '{"type":"assistant","message":{"content":[]}}' 0
bg "re-entrancy: nudges once, never traps" "$LAUNCH" 0 "true"

# The session transcript is NOT the input. A sibling's launch quoted into the
# session file - by an operator mining a transcript, or a role reading a log -
# must not be read as this agent's own work (live, 2026-07-21: two legs were
# blocked naming a task neither had launched).
printf '%s' "$LAUNCH" > "$work/session.jsonl"
printf '{"type":"assistant","message":{"content":[]}}' > "$work/bg.jsonl"
printf '{"agent_type":"shipshape:qm","transcript_path":"%s","agent_transcript_path":"%s"}' \
  "$work/session.jsonl" "$work/bg.jsonl" | "$scripts/background-custody.sh" >/dev/null 2>&1
[ $? -eq 0 ] && pass=$((pass + 1)) || { fail=$((fail + 1)); echo "FAIL: background-custody reads the session transcript"; }

# ... and the agent's own transcript still blocks when it is the one at fault.
printf '%s' '{"type":"assistant","message":{"content":[]}}' > "$work/session.jsonl"
printf '%s' "$LAUNCH" > "$work/bg.jsonl"
printf '{"agent_type":"shipshape:qm","transcript_path":"%s","agent_transcript_path":"%s"}' \
  "$work/session.jsonl" "$work/bg.jsonl" | "$scripts/background-custody.sh" >/dev/null 2>&1
[ $? -eq 2 ] && pass=$((pass + 1)) || { fail=$((fail + 1)); echo "FAIL: background-custody misses the agent's own stall"; }

# A read while the task is STILL RUNNING is not consumption: the turn ends
# holding live work regardless of a mid-flight look at the output file.
RUNNING='[{"id":"bx1","type":"shell","status":"running","description":"sweep"}]'
DONE='[{"id":"bx1","type":"shell","status":"completed","description":"sweep"}]'
CHILD='[{"id":"a99","type":"subagent","status":"running","description":"crew"}]'
bg "mid-flight read of a running task still blocks" "$LAUNCH
$READIT" 2 "false" "$RUNNING"
bg "read of a completed task passes" "$LAUNCH
$READIT" 0 "false" "$DONE"
bg "a running Agent child is still not the fault" "$AGENTC" 0 "false" "$CHILD"

# a foreign agent is out of custody's reach
printf '%s' "$LAUNCH" > "$work/bg.jsonl"
printf '{"agent_type":"general-purpose","agent_transcript_path":"%s"}' "$work/bg.jsonl" \
  | "$scripts/background-custody.sh" >/dev/null 2>&1
[ $? -eq 0 ] && pass=$((pass + 1)) || { fail=$((fail + 1)); echo "FAIL: background-custody ignores foreign agent"; }

# every hook script named in hooks.json exists and is executable
for h in $(grep -o 'hooks/scripts/[a-z-]*\.sh' "$repo/hooks/hooks.json" | sort -u); do
  [ -x "$repo/$h" ] && pass=$((pass + 1)) || { fail=$((fail + 1)); echo "FAIL: $h missing or not executable"; }
done

# frozen sentinel: in the Captain template, in no other hook script, absent from every deny message
grep -q "STOP. Captain's notes" "$repo/skills/captain/SKILL.md" && pass=$((pass + 1)) || { fail=$((fail + 1)); echo "FAIL: sentinel present in Captain template"; }
stray=$(grep -rl "STOP. Captain's notes" "$repo/hooks" | grep -v dispatch-guard.sh)
[ -z "$stray" ] && pass=$((pass + 1)) || { fail=$((fail + 1)); echo "FAIL: sentinel leaked into: $stray"; }

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

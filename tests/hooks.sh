#!/bin/sh
# Shipshape hook tests. Run: sh tests/hooks.sh
# Exercises the custody and guard scripts against fixture payloads.
# Exits nonzero on any failure.

set -u

repo=$(cd "$(dirname "$0")/.." && pwd)
scripts="$repo/hooks/scripts"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/proj/src" "$work/proj/features/steps"
printf 'plain user session, no marker\n' > "$work/t-main.jsonl"
printf 'earlier: Launching skill: captain\n' > "$work/t-dirty.jsonl"
cat > "$work/proj/RIGGING.md" <<'RIG'
## Stack

- language: typescript

## Directories

- implementation: src/
- specs: features/
- verification: features/steps/, features/support/
- assets: assets/

## Commands

- focused: `run {scenario}`

## Perturbation

- fail-fast: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`
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
check "foreign agent unrestricted" write-custody.sh "$(p "Explore" "$work/proj/features/pay.feature")" 0
check "main loop unrestricted" write-custody.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"file_path\":\"$work/proj/features/pay.feature\"}}" 0
check "quoted agent_type cannot match" write-custody.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"file_path\":\"$work/proj/features/pay.feature\",\"content\":\"mentions \\\"agent_type\\\": \\\"shipshape:crew\\\"\"}}" 0

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
check "boatswain may read CAPTAIN.md" captain-notes-guard.sh "$(p "shipshape:boatswain" "$work/proj/CAPTAIN.md")" 0
check "foreign agent reads unrestricted" captain-notes-guard.sh "$(p "Explore" "$work/proj/CAPTAIN.md")" 0
check "main loop reads unrestricted" captain-notes-guard.sh "{\"cwd\":\"$work/proj\",\"tool_input\":{\"file_path\":\"$work/proj/CAPTAIN.md\"}}" 0
check "qm other reads unaffected" captain-notes-guard.sh "$(p "shipshape:qm" "$work/proj/features/pay.feature")" 0
check "crew blocked from cat CAPTAIN.md" bash-custody.sh "$(b "shipshape:crew" "cat CAPTAIN.md")" 2
check "boatswain may cat CAPTAIN.md" bash-custody.sh "$(b "shipshape:boatswain" "cat CAPTAIN.md")" 0

# qm-entry-guard
check "qm refused on captain context" qm-entry-guard.sh "{\"transcript_path\":\"$work/t-dirty.jsonl\",\"tool_input\":{\"skill\":\"qm\"}}" 2
check "qm allowed on clean context" qm-entry-guard.sh "{\"transcript_path\":\"$work/t-main.jsonl\",\"tool_input\":{\"skill\":\"qm\"}}" 0
check "other skills unaffected" qm-entry-guard.sh "{\"transcript_path\":\"$work/t-dirty.jsonl\",\"tool_input\":{\"skill\":\"crew\"}}" 0

# feature-quality
printf 'Feature: Pay\n\n  Scenario: Pays\n    Given a card\n    When paying\n    Then paid\n' > "$work/proj/features/good.feature"
printf 'Scenario: floating scenario with no steps\n' > "$work/proj/features/bad.feature"
check "well-formed feature passes" feature-quality.sh "$(p "Explore" "$work/proj/features/good.feature")" 0
check "malformed feature blocked" feature-quality.sh "$(p "Explore" "$work/proj/features/bad.feature")" 2
check "non-feature files ignored" feature-quality.sh "$(p "Explore" "$work/proj/src/pay.ts")" 0

# rigging-validate
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$scripts/rigging-validate.sh")
if [ -z "$out" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: complete RIGGING.md is silent"; fi
grep -v 'fail-fast' "$work/proj/RIGGING.md" > "$work/proj/RIGGING.tmp" && mv "$work/proj/RIGGING.tmp" "$work/proj/RIGGING.md"
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$scripts/rigging-validate.sh")
case "$out" in
  *fail-fast*) pass=$((pass + 1)) ;;
  *) fail=$((fail + 1)); echo "FAIL: missing fail-fast is reported" ;;
esac

# planks-check
cd "$work/proj" && git init -q . && git add -A && git -c user.email=t@t -c user.name=t commit -qm init
cat >> "$work/proj/RIGGING.md" <<'RIG'
- fail-fast: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`
RIG
printf 'export function pay() {}\n' > "$work/proj/src/unplanked.ts"
git add -A
check "unplanked change blocked for crew" planks-check.sh "{\"agent_type\":\"shipshape:crew\",\"cwd\":\"$work/proj\"}" 2
printf '/**\n * @planks("When paying")\n */\nexport function pay() {}\n' > "$work/proj/src/unplanked.ts"
check "planked change passes for crew" planks-check.sh "{\"agent_type\":\"shipshape:crew\",\"cwd\":\"$work/proj\"}" 0
check "main loop planks unrestricted" planks-check.sh "{\"cwd\":\"$work/proj\"}" 0

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

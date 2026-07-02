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
printf 'system prompt SHIPSHAPE-ROLE: crew\n' > "$work/t-crew.jsonl"
printf 'system prompt SHIPSHAPE-ROLE: qm\n' > "$work/t-qm.jsonl"
printf 'system prompt SHIPSHAPE-ROLE: boatswain\n' > "$work/t-boatswain.jsonl"
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
  printf '{"transcript_path":"%s","cwd":"%s","tool_input":{"file_path":"%s"}}' "$1" "$work/proj" "$2"
}
b() {
  printf '{"transcript_path":"%s","cwd":"%s","tool_input":{"command":"%s"}}' "$1" "$work/proj" "$2"
}

# write-custody
check "crew blocked from specs" write-custody.sh "$(p "$work/t-crew.jsonl" "$work/proj/features/pay.feature")" 2
check "crew allowed in src" write-custody.sh "$(p "$work/t-crew.jsonl" "$work/proj/src/pay.ts")" 0
check "crew blocked from step defs" write-custody.sh "$(p "$work/t-crew.jsonl" "$work/proj/features/steps/pay.steps.ts")" 2
check "crew blocked from RIGGING.md" write-custody.sh "$(p "$work/t-crew.jsonl" "$work/proj/RIGGING.md")" 2
check "qm blocked from src" write-custody.sh "$(p "$work/t-qm.jsonl" "$work/proj/src/pay.ts")" 2
check "qm allowed in step defs" write-custody.sh "$(p "$work/t-qm.jsonl" "$work/proj/features/steps/pay.steps.ts")" 0
check "qm blocked from specs" write-custody.sh "$(p "$work/t-qm.jsonl" "$work/proj/features/pay.feature")" 2
check "boatswain blocked from CAPTAIN.md" write-custody.sh "$(p "$work/t-boatswain.jsonl" "$work/proj/CAPTAIN.md")" 2
check "boatswain allowed hygiene edits" write-custody.sh "$(p "$work/t-boatswain.jsonl" "$work/proj/src/pay.ts")" 0
check "main loop unrestricted" write-custody.sh "$(p "$work/t-main.jsonl" "$work/proj/features/pay.feature")" 0

# bash-custody
check "crew blocked from git commit" bash-custody.sh "$(b "$work/t-crew.jsonl" "git commit -m x")" 2
check "boatswain allowed git commit" bash-custody.sh "$(b "$work/t-boatswain.jsonl" "git commit -m x")" 0
check "boatswain blocked from git push" bash-custody.sh "$(b "$work/t-boatswain.jsonl" "git push origin main")" 2
check "qm blocked from publish" bash-custody.sh "$(b "$work/t-qm.jsonl" "npm publish")" 2
check "main loop push unrestricted" bash-custody.sh "$(b "$work/t-main.jsonl" "git push origin main")" 0

# qm-entry-guard
check "qm refused on captain context" qm-entry-guard.sh "{\"transcript_path\":\"$work/t-dirty.jsonl\",\"tool_input\":{\"skill\":\"qm\"}}" 2
check "qm allowed on clean context" qm-entry-guard.sh "{\"transcript_path\":\"$work/t-main.jsonl\",\"tool_input\":{\"skill\":\"qm\"}}" 0
check "other skills unaffected" qm-entry-guard.sh "{\"transcript_path\":\"$work/t-dirty.jsonl\",\"tool_input\":{\"skill\":\"crew\"}}" 0

# feature-quality
printf 'Feature: Pay\n\n  Scenario: Pays\n    Given a card\n    When paying\n    Then paid\n' > "$work/proj/features/good.feature"
printf 'Scenario: floating scenario with no steps\n' > "$work/proj/features/bad.feature"
check "well-formed feature passes" feature-quality.sh "$(p "$work/t-main.jsonl" "$work/proj/features/good.feature")" 0
check "malformed feature blocked" feature-quality.sh "$(p "$work/t-main.jsonl" "$work/proj/features/bad.feature")" 2
check "non-feature files ignored" feature-quality.sh "$(p "$work/t-main.jsonl" "$work/proj/src/pay.ts")" 0

# rigging-validate
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$scripts/rigging-validate.sh")
if [ -z "$out" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: complete RIGGING.md is silent"; fi
sed -i '/fail-fast/d' "$work/proj/RIGGING.md"
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
check "unplanked change blocked for crew" planks-check.sh "{\"transcript_path\":\"$work/t-crew.jsonl\",\"cwd\":\"$work/proj\"}" 2
printf '/**\n * @planks("When paying")\n */\nexport function pay() {}\n' > "$work/proj/src/unplanked.ts"
check "planked change passes for crew" planks-check.sh "{\"transcript_path\":\"$work/t-crew.jsonl\",\"cwd\":\"$work/proj\"}" 0
check "main loop planks unrestricted" planks-check.sh "{\"transcript_path\":\"$work/t-main.jsonl\",\"cwd\":\"$work/proj\"}" 0

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

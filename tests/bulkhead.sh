#!/bin/sh
# Shipshape bulkhead conformance. Run: sh tests/bulkhead.sh
#
# The "Passing verification is not proof" Article applied to the bulkhead itself: each known leak path is
# exercised against the hooks with full realistic payloads matching the
# runtime's observed hook schema, so a hook regression reddens here.
# Exits nonzero on any failure.
#
# Live-fire procedure, run inside a supporting runtime session when a
# hook or the runtime changes: dispatch a shipshape role agent and have
# it attempt each path below; every attempt MUST be blocked with a
# message naming the true role. Payload conformance here is necessary,
# not sufficient; the live-fire is the claim per the claims policy.

set -u

repo=$(cd "$(dirname "$0")/.." && pwd)
scripts="$repo/hooks/scripts"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/proj"
# a transcript carrying Captain context, as the main-loop session accumulates
printf 'earlier: Launching skill: captain\n' > "$work/t.jsonl"

pass=0
fail=0

# full payload in the runtime's observed schema
leak() {
  name="$1" script="$2" agent="$3" tool="$4" input="$5" want="$6"
  payload="{\"session_id\":\"t\",\"transcript_path\":\"$work/t.jsonl\",\"cwd\":\"$work/proj\",\"permission_mode\":\"default\",\"agent_id\":\"t1\",\"agent_type\":\"$agent\",\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"$tool\",\"tool_input\":$input,\"tool_use_id\":\"t\"}"
  printf '%s' "$payload" | "$scripts/$script" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: $name: want $want, got $got"; fi
}

# leak path: direct read of Captain's notes
leak "read leak blocked" captain-notes-guard.sh "shipshape:qm" "Read" "{\"file_path\":\"$work/proj/CAPTAIN.md\"}" 2
# leak path: shell side channel
leak "bash cat leak blocked" bash-custody.sh "shipshape:crew" "Bash" "{\"command\":\"cat CAPTAIN.md\"}" 2
# leak path: search naming the file
leak "grep leak blocked" captain-notes-guard.sh "shipshape:shipwright" "Grep" "{\"pattern\":\"x\",\"path\":\"CAPTAIN.md\"}" 2
# leak path: sentinel forwarded in a dispatch
leak "sentinel dispatch blocked" dispatch-guard.sh "shipshape:qm" "Task" "{\"subagent_type\":\"shipshape:crew\",\"prompt\":\"context: STOP. Captain's notes: non-binding\"}" 2
# leak path: fat Captain-seat dispatch
fat=$(i=0; s=""; while [ $i -lt 60 ]; do s="${s}0123456789012345678901234567890123456789012345678"; i=$((i+1)); done; printf '%s' "$s")
payload="{\"session_id\":\"t\",\"transcript_path\":\"$work/t.jsonl\",\"cwd\":\"$work/proj\",\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Task\",\"tool_input\":{\"subagent_type\":\"shipshape:qm\",\"prompt\":\"$fat\"},\"tool_use_id\":\"t\"}"
printf '%s' "$payload" | "$scripts/dispatch-guard.sh" >/dev/null 2>&1
if [ $? -eq 2 ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: fat dispatch blocked"; fi
# leak path: internal role reads the session transcript off disk
leak "transcript read leak blocked (qm)" bash-custody.sh "shipshape:qm" "Bash" "{\"command\":\"cat $work/t.jsonl\"}" 2
leak "transcript read leak blocked (crew)" bash-custody.sh "shipshape:crew" "Bash" "{\"command\":\"wc -l $work/t.jsonl\"}" 2
# leak path: Boatswain reads Captain notes or the transcript
leak "boatswain notes read blocked" captain-notes-guard.sh "shipshape:boatswain" "Read" "{\"file_path\":\"$work/proj/CAPTAIN.md\"}" 2
leak "boatswain transcript read blocked" bash-custody.sh "shipshape:boatswain" "Bash" "{\"command\":\"cat $work/t.jsonl\"}" 2
# legitimate paths stay open
# leak path: git's content-dumping readers. A diff or history read prints the content of
# every changed file, reads no ignore artifact, and NAMES nothing, so neither the notecheck
# nor the search branch can see it. Found in real use by a consuming project, 2026-07-20.
leak "unscoped git diff blocked" bash-custody.sh "shipshape:qm" "Bash" "{\"command\":\"git diff\"}" 2
leak "git diff against a base blocked" bash-custody.sh "shipshape:qm" "Bash" "{\"command\":\"git diff 5058b35\"}" 2
leak "git show blocked" bash-custody.sh "shipshape:boatswain" "Bash" "{\"command\":\"git show HEAD\"}" 2
leak "git log -p blocked" bash-custody.sh "shipshape:crew" "Bash" "{\"command\":\"git log -p\"}" 2
leak "git stash show -p blocked" bash-custody.sh "shipshape:qm" "Bash" "{\"command\":\"git stash show -p\"}" 2
# the guarded forms roles genuinely need stay open: the exclusion pathspec, and the
# content-free summaries. Guard the form, never the command.
leak "excluded git diff stays open" bash-custody.sh "shipshape:qm" "Bash" "{\"command\":\"git diff 5058b35 -- . ':!CAPTAIN.md'\"}" 0
leak "git diff --stat stays open" bash-custody.sh "shipshape:boatswain" "Bash" "{\"command\":\"git diff --stat\"}" 0
leak "git diff --name-only stays open" bash-custody.sh "shipshape:qm" "Bash" "{\"command\":\"git diff --name-only\"}" 0
leak "git log --oneline stays open" bash-custody.sh "shipshape:qm" "Bash" "{\"command\":\"git log --oneline -5\"}" 0
leak "opening retrieval with exclusion stays open" bash-custody.sh "shipshape:boatswain" "Bash" "{\"command\":\"cat RIGGING.md && git status && git diff 5058b35 -- . ':!CAPTAIN.md' && git log -n 5\"}" 0

leak "thin dispatch stays open" dispatch-guard.sh "shipshape:qm" "Task" "{\"subagent_type\":\"shipshape:crew\",\"prompt\":\"Target: f.feature:X. Failure: expected Y.\"}" 0

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

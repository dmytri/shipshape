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
# legitimate paths stay open
leak "boatswain read stays open" captain-notes-guard.sh "shipshape:boatswain" "Read" "{\"file_path\":\"$work/proj/CAPTAIN.md\"}" 0
leak "boatswain transcript read stays open" bash-custody.sh "shipshape:boatswain" "Bash" "{\"command\":\"cat $work/t.jsonl\"}" 0
leak "thin dispatch stays open" dispatch-guard.sh "shipshape:qm" "Task" "{\"subagent_type\":\"shipshape:crew\",\"prompt\":\"Target: f.feature:X. Failure: expected Y.\"}" 0

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

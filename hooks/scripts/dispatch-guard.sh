#!/bin/sh
# Shipshape dispatch guard. PreToolUse guard for Task.
#
# Enforces the dispatch contract from skills/shipshape/SKILL.md: a
# Captain-originated dispatch to an internal role carries the role, the
# base commit, and an optional watchbill pointer, nothing else, and no
# dispatch forwards Captain's notes. Doctrine lives in the skills; this
# script adds none.
#
# Role identity: the runtime names the dispatching agent in the hook
# payload as agent_type. A payload with no shipshape agent_type is the
# Captain seat: the main loop or Captain. The length cap applies to
# Captain-seat dispatches only; QM dispatches carry failure evidence and
# are exempt. The sentinel check applies to every dispatcher.

payload=$(cat)

target=$(printf '%s' "$payload" | sed -n 's/.*"subagent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
[ -z "$target" ] && exit 0

case "$payload" in
  *"STOP. Captain's notes"*)
    echo "Shipshape dispatch guard: the dispatch to $target carries the Captain-notes banner. Captain content crosses no bulkhead. Remove it and re-dispatch. (Article: Context bulkhead.)" >&2
    exit 2
    ;;
esac

dispatcher=$(printf '%s' "$payload" | sed -n 's/.*"agent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
if [ -z "$dispatcher" ]; then
  if [ "${#payload}" -gt 2500 ]; then
    echo "Shipshape dispatch guard: the dispatch to $target exceeds the thin-dispatch cap. A Captain-originated dispatch carries the role, the base commit, and an optional watchbill pointer; the durable artifacts are the hand-off. Trim and re-dispatch. (Dispatch contract.)" >&2
    exit 2
  fi
fi

exit 0

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
# Captain seat: the main loop or Captain. A spawned Captain carries
# agent_type shipshape:captain and holds the same seat, so the cap
# binds there too: a Captain-originated dispatch carries the role, the
# base commit, and an optional watchbill pointer, whoever spawned the
# Captain. QM dispatches carry failure evidence and are exempt. The
# sentinel check applies to every dispatcher. The cap measures the
# dispatch prompt, not the whole payload, so runtime fields such as
# long environment paths spend none of the budget.

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
case "$dispatcher" in
  ''|captain)
    # Bound the measure to the prompt string. JSON-escaped quotes are
    # swapped for an unprintable placeholder before extraction so a
    # quoted fragment cannot truncate the prompt, then restored.
    esc=$(printf '\001')
    prompt=$(printf '%s' "$payload" | sed "s/\\\\\"/$esc/g" | sed -n 's/.*"prompt":[[:space:]]*"\([^"]*\)".*/\1/p' | tr "$esc" '"')
    if [ "${#prompt}" -gt 2500 ]; then
      echo "Shipshape dispatch guard: the dispatch to $target exceeds the thin-dispatch cap. A Captain-originated dispatch carries the role, the base commit, and an optional watchbill pointer; the durable artifacts are the hand-off. Trim and re-dispatch. (Dispatch contract.)" >&2
      exit 2
    fi
    ;;
esac

exit 0

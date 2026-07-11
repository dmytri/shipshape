#!/bin/sh
# Shipshape Captain-notes read guard. PreToolUse guard for Read/Grep/Glob.
#
# Enforces the CAPTAIN.md access rule from the Captain skill: Captain writes
# and trims the notes, and no other role reads them. Mechanizes the Context
# bulkhead Article for direct reads and for searches that name the file; a
# broad search that surfaces the file without naming it stays with skill
# discipline. Doctrine lives in the skills; this script adds none.
#
# Role identity: the runtime names the running agent in the hook payload
# as agent_type, such as "shipshape:crew". Payloads with no shipshape
# agent_type are the human-facing main loop or a foreign agent; custody
# does not apply there. Quoted mentions of the field inside tool_input
# arrive JSON-escaped and cannot match the unescaped top-level key.

payload=$(cat)

role=$(printf '%s' "$payload" | sed -n 's/.*"agent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
[ -z "$role" ] && exit 0

case "$role" in
  qm|crew|boatswain|shipwright) : ;;
  *) exit 0 ;;
esac

case "$payload" in
  *CAPTAIN.md*)
    echo "Shipshape custody: $role MUST NOT read CAPTAIN.md. Captain-only non-binding notes; no role but Captain reads them. Derive everything from durable artifacts. (Article: Context bulkhead.)" >&2
    exit 2
    ;;
esac

# The session transcript is a discarded side channel, never product intent
# (Role transitions: "an internal role MUST NOT mine it"). Block a Read,
# Grep, or Glob that names the transcript file by path or basename. The
# transcript path is read from the payload, so it cannot be spoofed.
transcript=$(printf '%s' "$payload" | sed -n 's/.*"transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
if [ -n "$transcript" ]; then
  tbase=$(basename "$transcript")
  fp=$(printf '%s' "$payload" | sed -n 's/.*"file_path":[[:space:]]*"\([^"]*\)".*/\1/p')
  pat=$(printf '%s' "$payload" | sed -n 's/.*"pattern":[[:space:]]*"\([^"]*\)".*/\1/p')
  pth=$(printf '%s' "$payload" | sed -n 's/.*"path":[[:space:]]*"\([^"]*\)".*/\1/p')
  for v in "$fp" "$pat" "$pth"; do
    case "$v" in
      *"$tbase"*|*"$transcript"*)
        echo "Shipshape custody: $role MUST NOT read the session transcript. It is discarded chat, not product intent. Derive everything from durable artifacts. (Article: Context bulkhead.)" >&2
        exit 2
        ;;
    esac
  done
fi

exit 0

#!/bin/sh
# Shipshape Captain-notes read guard. PreToolUse guard for Read/Grep/Glob.
#
# Enforces the CAPTAIN.md access rule: skills/qm/SKILL.md "MUST NOT read
# CAPTAIN.md", and the Captain-notes access rule that Boatswain MAY read the
# file while Quartermaster, Crew Mate, and Shipwright MUST NOT. Mechanizes
# the Article 2 firewall for direct reads and for searches that name the
# file; a broad search that surfaces the file without naming it stays with
# skill discipline. Doctrine lives in the skills; this script adds none.
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
  qm|crew|shipwright) : ;;
  *) exit 0 ;;
esac

case "$payload" in
  *CAPTAIN.md*)
    echo "Shipshape custody: $role MUST NOT read CAPTAIN.md. Captain-only non-binding notes; Boatswain MAY read them, QM, Crew, and Shipwright derive everything from durable artifacts. (Article 2: context firewall.)" >&2
    exit 2
    ;;
esac

exit 0

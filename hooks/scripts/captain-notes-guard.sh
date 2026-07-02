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
# Role identity: Shipshape role agents declare "SHIPSHAPE-ROLE: <role>" in
# their system prompt. Sessions with no marker are the human-facing main
# loop; the guard does not apply there.

payload=$(cat)

transcript=$(printf '%s' "$payload" | sed -n 's/.*"transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
role=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  role=$(grep -m1 -o 'SHIPSHAPE-ROLE: [a-z]*' "$transcript" | cut -d' ' -f2)
fi
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

#!/bin/sh
# Shipshape QM entry guard. PreToolUse guard for Skill invocations.
#
# Enforces Article 2 (context firewall) from skills/shipshape/SKILL.md and
# the QM context firewall in skills/qm/SKILL.md: "Run only after Captain
# context is cleared or runtime auto-cleared. ... QM refuses if Captain or
# human discovery context is visible." Doctrine lives in the skills; this
# script adds none.

payload=$(cat)

case "$payload" in
  *'"skill"'*) : ;;
  *) exit 0 ;;
esac

skill=$(printf '%s' "$payload" | sed -n 's/.*"skill":[[:space:]]*"\([^"]*\)".*/\1/p')
[ "$skill" = "qm" ] || exit 0

transcript=$(printf '%s' "$payload" | sed -n 's/.*"transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

if grep -q -e 'SHIPSHAPE-ROLE: captain' -e 'command-name>/captain' -e 'Launching skill: captain' -e '"skill":[[:space:]]*"captain"' "$transcript"; then
  echo 'No. Captain context visible. Need clear context, then QM. (Article 2: context firewall.)' >&2
  exit 2
fi

exit 0

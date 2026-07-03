#!/bin/sh
# Shipshape QM entry guard. PreToolUse guard for Skill invocations.
#
# Enforces Article 2 (context firewall) from skills/shipshape/SKILL.md and
# the QM context firewall in skills/qm/SKILL.md. Window isolation is the
# firewall floor: a QM subagent with a fresh context window carries no
# Captain content and is allowed, named in the payload as agent_type
# "shipshape:qm". A same-session /qm from the main loop has no isolation,
# so this guard refuses when Captain context shows in the transcript.
# Doctrine lives in the skills; this script adds none.

payload=$(cat)

case "$payload" in
  *'"skill"'*) : ;;
  *) exit 0 ;;
esac

skill=$(printf '%s' "$payload" | sed -n 's/.*"skill":[[:space:]]*"\([^"]*\)".*/\1/p')
case "$skill" in
  qm|shipshape:qm) : ;;
  *) exit 0 ;;
esac

# A window-isolated QM subagent carries no Captain content in its context
# window, which satisfies the clean-context firewall (Role transitions:
# "a fresh context window ... satisfies the clean-context firewall").
# The runtime names it in the payload as agent_type "shipshape:qm". The
# shared on-disk transcript is a residual side channel closed by command
# custody, not by refusing entry. Allow the isolated subagent.
role=$(printf '%s' "$payload" | sed -n 's/.*"agent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
[ "$role" = "qm" ] && exit 0

# Otherwise this is the human-facing main loop invoking /qm without
# isolation. Its transcript is its window; refuse if Captain context shows.
transcript=$(printf '%s' "$payload" | sed -n 's/.*"transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

if grep -q -e 'command-name>/captain' -e 'command-name>/shipshape:captain' -e 'Launching skill: captain' -e 'Launching skill: shipshape:captain' -e '"skill":[[:space:]]*"captain"' -e '"skill":[[:space:]]*"shipshape:captain"' "$transcript"; then
  echo 'No. Captain context visible in this session. Start a fresh session, then QM. A window-isolated QM subagent is allowed; a same-session /qm is not. (Article 2: context firewall.)' >&2
  exit 2
fi

exit 0

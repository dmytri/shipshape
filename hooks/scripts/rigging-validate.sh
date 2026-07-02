#!/bin/sh
# Shipshape rigging validation. SessionStart hook.
#
# Enforces the RIGGING.md validation rule from skills/shipshape/SKILL.md:
# "Roles validate RIGGING.md on read. A malformed file or a missing required
# value is a configuration blocker to Captain." The required values are
# language, implementation, focused, and fail-fast. Doctrine lives in the
# skills; this script adds none.

payload=$(cat)
cwd=$(printf '%s' "$payload" | sed -n 's/.*"cwd":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$cwd" ] || cwd=$(pwd)
rig="$cwd/RIGGING.md"
[ -f "$rig" ] || exit 0

missing=""
grep -q '^- language:[[:space:]]*[^[:space:]]' "$rig" || missing="$missing language"
grep -q '^- implementation:[[:space:]]*[^[:space:]]' "$rig" || missing="$missing implementation"
grep -q '^- focused:[[:space:]]*[^[:space:]]' "$rig" || missing="$missing focused"
grep -q '^- fail-fast:[[:space:]]*[^[:space:]]' "$rig" || missing="$missing fail-fast"

if [ -n "$missing" ]; then
  echo "Shipshape: RIGGING.md is missing required values:$missing. This is a configuration blocker to Captain."
fi

exit 0

#!/bin/sh
# Shipshape feature quality gate. PostToolUse hook for Edit/Write/MultiEdit.
#
# Enforces the scenario-writing agreement from skills/shipshape/SKILL.md and
# the Boatswain hygiene check from skills/boatswain/SKILL.md: "Touched
# .feature files: concrete, executable, current, not padded" and "Prefer
# available hygiene tools from project configuration, including gplint when
# present." Doctrine lives in the skills; this script adds none.

payload=$(cat)
file_path=$(printf '%s' "$payload" | sed -n 's/.*"file_path":[[:space:]]*"\([^"]*\)".*/\1/p')
case "$file_path" in
  *.feature) : ;;
  *) exit 0 ;;
esac
[ -f "$file_path" ] || exit 0

problems=""

grep -q 'Feature:' "$file_path" || problems="$problems
- file has no Feature: declaration"

grep -q "$(printf '\t')" "$file_path" && problems="$problems
- file contains tabs; the scenario-writing agreement uses 2-space indentation"

if grep -q 'Scenario' "$file_path"; then
  grep -qE '^[[:space:]]*(Given|When|Then) ' "$file_path" || problems="$problems
- scenarios declare no Given, When, or Then steps"
fi

if command -v gplint >/dev/null 2>&1; then
  lint_out=$(gplint "$file_path" 2>&1) || problems="$problems
- gplint: $lint_out"
fi

if [ -n "$problems" ]; then
  echo "Shipshape feature quality: $file_path violates the scenario-writing agreement:$problems" >&2
  exit 2
fi

exit 0

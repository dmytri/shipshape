#!/bin/sh
# Shipshape feature quality gate. PostToolUse hook for Edit/Write/MultiEdit.
#
# Enforces the scenario-writing agreement from skills/shipshape/SKILL.md and
# the Captain skill's write-time lint duty: "Lint authored specs and assets
# at write time", and "Bare # comments in .feature files ... crosses the
# Context bulkhead by construction". Doctrine lives in the skills; this
# script adds none.

payload=$(cat)
file_path=$(printf '%s' "$payload" | sed -n 's/.*"file_path":[[:space:]]*"\([^"]*\)".*/\1/p')
case "$file_path" in
  *.feature) : ;;
  *) exit 0 ;;
esac
[ -f "$file_path" ] || exit 0

# Apply only inside a Shipshape project. Resolved by walking up from the file, not
# from the session cwd, which is not the project root whenever a role works in a
# tree the session did not start in - see write-custody.sh for the live proof.
cwd=$(printf '%s' "$payload" | sed -n 's/.*"cwd":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$cwd" ] || cwd=$(pwd)
fq_root=""
fq_d=$(dirname "$file_path")
while [ -n "$fq_d" ] && [ "$fq_d" != "/" ] && [ "$fq_d" != "." ]; do
  if [ -f "$fq_d/RIGGING.md" ]; then fq_root="$fq_d"; break; fi
  fq_d=$(dirname "$fq_d")
done
[ -z "$fq_root" ] && [ -f "$cwd/RIGGING.md" ] && fq_root="$cwd"
[ -n "$fq_root" ] || exit 0

problems=""

grep -q 'Feature:' "$file_path" || problems="$problems
- file has no Feature: declaration"

grep -q "^[ ]*$(printf '\t')" "$file_path" && problems="$problems
- indentation uses tabs; the scenario-writing agreement uses 2-space indentation"

if grep -q 'Scenario' "$file_path"; then
  grep -qE '^[[:space:]]*(Given|When|Then) ' "$file_path" || problems="$problems
- scenarios declare no Given, When, or Then steps"
fi

# The scenario-writing agreement bans bare # comments: "Bare # comments
# in .feature files ... crosses the Context bulkhead by construction".
# The Gherkin "# language: xx" directive is parser configuration, not a
# comment, and a # line inside a doc string is step data owned by the
# triple-quote delimiters, so both stay open.
awk '
  /^[[:space:]]*("""|```)/ { indoc = 1 - indoc; next }
  indoc { next }
  /^[[:space:]]*#[[:space:]]*language[[:space:]]*:/ { next }
  /^[[:space:]]*#/ { bare = 1 }
  END { exit bare ? 0 : 1 }
' "$file_path" && problems="$problems
- contains a # comment; the Context bulkhead disallows comments in .feature files, durable context belongs in Rule: prose, non-durable notes belong in CAPTAIN.md"

if command -v gplint >/dev/null 2>&1; then
  lint_out=$(gplint "$file_path" 2>&1) || problems="$problems
- gplint: $lint_out"
fi

if [ -n "$problems" ]; then
  echo "Shipshape feature quality: $file_path violates the scenario-writing agreement:$problems" >&2
  exit 2
fi

exit 0

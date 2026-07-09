#!/bin/sh
# Shipshape style conformance. Run: sh tests/style.sh
#
# The "Passing verification is not proof" Article applied to Controlled
# English and the citation convention: each rule below is executable, so
# violations redden instead of relying on prose discipline.
#
# Checked files: skill text, agent adapters, commands, rule files, hook
# scripts, the structural map, the agent index, and AGENTS.md. README is
# exempt only for its Ship of Theseus section per AGENTS.md; the README
# is not scanned here because the exempt section cannot be excluded by
# line-oriented grep.

set -u

repo=$(cd "$(dirname "$0")/.." && pwd)
files="$repo/skills/*/SKILL.md $repo/agents/*.md $repo/commands/*.md $repo/rules/*.mdc $repo/hooks/scripts/*.sh $repo/shipshape.md $repo/llms.txt $repo/AGENTS.md"

pass=0
fail=0

check() {
  label="$1"
  pattern="$2"
  hits=$(grep -rnE "$pattern" $files 2>/dev/null)
  if [ -n "$hits" ]; then
    fail=$((fail + 1))
    echo "FAIL: $label"
    echo "$hits" | head -5
  else
    pass=$((pass + 1))
  fi
}

# Articles are cited by title. A numeric citation breaks on resequence.
check "numeric Article citation" 'Article [0-9]'

# The Captain to QM barrier is the context bulkhead.
check "stale firewall vocabulary" '[Ff]irewall'

# Controlled English uses only US 101-key keyboard characters.
# Octal escapes: POSIX printf has no \x, and dash renders \x literally,
# which once made this check vacuously green. Em dash, en dash, left and
# right double quotes, left and right single quotes, ellipsis,
# non-breaking space, right arrow, left arrow, double right arrow.
nonascii=$(printf '\342\200\224|\342\200\223|\342\200\234|\342\200\235|\342\200\230|\342\200\231|\342\200\246|\302\240|\342\206\222|\342\206\220|\342\207\222')

# Self-test: the pattern must match a real em dash before it is trusted.
# A pattern that cannot match its own probe is an inert check, and an
# inert check is unproven per the Verification policy.
probe=$(printf '\342\200\224')
if printf '%s\n' "$probe" | grep -qE "$nonascii"; then
  pass=$((pass + 1))
else
  fail=$((fail + 1))
  echo "FAIL: non-ASCII pattern is inert; the check cannot redden"
fi

check "non-ASCII punctuation" "$nonascii"

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

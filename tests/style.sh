#!/bin/sh
# Shipshape style conformance. Run: sh tests/style.sh
#
# The "Passing verification is not proof" Article applied to Controlled
# English and the citation convention: each rule below is executable, so
# violations redden instead of relying on prose discipline.
#
# Checked files: skill text, agent adapters, commands, hook scripts, and
# the structural map. README is exempt per AGENTS.md.

set -u

repo=$(cd "$(dirname "$0")/.." && pwd)
files="$repo/skills/*/SKILL.md $repo/agents/*.md $repo/commands/*.md $repo/hooks/scripts/*.sh $repo/shipshape.md"

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
# Em dash, en dash, smart quotes, ellipsis, non-breaking space.
check "non-ASCII punctuation" "$(printf '\xe2\x80\x94|\xe2\x80\x93|\xe2\x80\x9c|\xe2\x80\x9d|\xe2\x80\x98|\xe2\x80\x99|\xe2\x80\xa6|\xc2\xa0')"

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

#!/bin/sh
# Shipshape doctrine-home test. Run: sh tests/homes.sh
#
# One home per rule, applied to the skills themselves. Every Article
# citation resolves to a real Article heading in the core skill, every
# cited section name exists as a heading, and distinctive rule sentences
# appear exactly once across the skills. Exits nonzero on any failure.

set -u

repo=$(cd "$(dirname "$0")/.." && pwd)
core="$repo/skills/shipshape/SKILL.md"
skillfiles=$(ls "$repo"/skills/*/SKILL.md)

pass=0
fail=0

# Every "Title" Article citation in skills and hooks names a numbered
# Article heading in the core skill, so a demoted or renamed Article
# cannot leave a dangling citation.
cites=$(grep -rho '"[^"]*" Article' $skillfiles "$repo"/hooks/scripts/*.sh "$repo"/rules/*.mdc 2>/dev/null | sed 's/^"//; s/" Article$//' | sort -u)
while IFS= read -r t; do
  [ -z "$t" ] && continue
  if grep -qF ". **$t.**" "$core"; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1)); echo "FAIL: cited Article has no core heading: $t"
  fi
done <<CITES
$cites
CITES

# Cited section names exist as headings somewhere in the skills.
for h in "Scenario-writing agreement" "Verification agreement" \
  "Blocker policy" "Watchbill policy" "Perturbation policy" \
  "Asset policy" "Artifact authority policy" "Verification policy" \
  "Outbound verification policy" "Planking agreement" "Harbour flow" \
  "Transient output" "Tier tags" "Rigging read contract" \
  "Rigging shape" "Context custody"; do
  if grep -q "^##* $h" $skillfiles; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1)); echo "FAIL: cited section heading missing: $h"
  fi
done

# One home per rule: each distinctive rule sentence appears exactly once
# across all skills. A count above one is a copy left behind by a move.
onehome() {
  probe="$1"
  n=$(grep -rhoF "$probe" $skillfiles | wc -l)
  if [ "$n" -eq 1 ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1)); echo "FAIL: rule has $n homes, wants 1: $probe"
  fi
}
onehome "namespace every created object"
onehome "A test double in the Meszaros sense is allowed only for one of three named conditions"
onehome "It selects and orders a subset of verification-discovered work"
onehome "poll the resource until it observably serves"
onehome "reset to a fresh context at durable voyage boundaries"
onehome "The minimum required values are"
onehome "and a multi-value key repeats on a new line"
onehome "Testability refactors MUST serve current verification-discovered work"
onehome "reason over the import graph"
onehome "smallest stable seam that owns the behaviour"
onehome "Normalize \`And\` and \`But\` to the inherited"
onehome "Selection MAY narrow intermediate confirmation"
onehome "a cadence change is a tier retag"
onehome "docblock or AST reader inventory every plank completely"
onehome "spent once its red list is dispatched"
onehome "reclassify it by striking it from the"
onehome "pin the behaviour that must survive"
onehome "cheapest legal layer"

# Shipwright templates travel with the skill; fitting out reads them.
if [ -f "$repo/skills/shipwright/templates.md" ]; then
  pass=$((pass + 1))
else
  fail=$((fail + 1)); echo "FAIL: skills/shipwright/templates.md is missing"
fi

# README rigging example conforms to the Rigging shape keys, so a copied
# example cannot teach a key the read contract rejects.
if grep -q '^- target:' "$repo/README.md"; then
  fail=$((fail + 1)); echo "FAIL: README rigging example uses 'target:' instead of 'outbound:'"
else
  pass=$((pass + 1))
fi
if grep -q '^- outbound:' "$repo/README.md" && grep -q '^- ship:' "$repo/README.md" && grep -q '^- verify:' "$repo/README.md"; then
  pass=$((pass + 1))
else
  fail=$((fail + 1)); echo "FAIL: README Outbound example missing outbound/ship/verify keys"
fi

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

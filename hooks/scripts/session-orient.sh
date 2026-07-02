#!/bin/sh
# Shipshape session orientation. SessionStart hook.
#
# Injects the structural map (shipshape.md, orientation only, skills are
# canonical) and one derived deck-state line. Mechanizes the entry routing
# from skills/shipshape/SKILL.md and the derived-state rule from the role
# skills: deck state is derived from durable signals, never stored.
# Doctrine lives in the skills; this script adds none.
#
# Injection is conditional: silent unless the project has RIGGING.md.

payload=$(cat)
cwd=$(printf '%s' "$payload" | sed -n 's/.*"cwd":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$cwd" ] || cwd=$(pwd)
[ -f "$cwd/RIGGING.md" ] || exit 0

root=$(cd "$(dirname "$0")/../.." && pwd)
[ -f "$root/shipshape.md" ] && cat "$root/shipshape.md"

if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
  tree="dirty"
  route="/boatswain cleans first"
else
  tree="clean"
  route="/captain"
fi
captains=$(grep -r -o '@captain' --include='*.feature' "$cwd" 2>/dev/null | wc -l | tr -d ' ')
condemned=$(grep -r -o '@shipwright' --include='*.feature' "$cwd" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "Deck state, derived now: tree $tree; @captain scenarios: $captains; @shipwright scenarios: $condemned. Suggested entry: $route."

exit 0

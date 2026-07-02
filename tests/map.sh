#!/bin/sh
# Shipshape map drift test. Run: sh tests/map.sh
# Every name the structural map uses must exist in the skills, and the
# session-orient hook must inject only when RIGGING.md is present.
# Exits nonzero on any failure.

set -u

repo=$(cd "$(dirname "$0")/.." && pwd)
map="$repo/shipshape.md"
skills=$(cat "$repo"/skills/*/SKILL.md)

pass=0
fail=0

need() {
  name="$1"
  if ! grep -qF "$name" "$map"; then
    fail=$((fail + 1)); echo "FAIL: map is missing: $name"; return
  fi
  case "$skills" in
    *"$name"*) pass=$((pass + 1)) ;;
    *) fail=$((fail + 1)); echo "FAIL: map names '$name' but no skill defines it" ;;
  esac
}

for n in Captain Quartermaster "Crew Mate" Boatswain Shipwright; do need "$n"; done
for n in ".feature" "assets/**" "AGENTS.md" "RIGGING.md" "CAPTAIN.md" "watchbill.json"; do need "$n"; done
for n in "@captain" "@shipwright" "@property" "@exceptional-double" "@logic" "@sandbox"; do need "$n"; done
for n in "@planks(" ; do need "$n"; done
for n in discover focused broad coverage step-usage plank-inventory typecheck lint; do need "$n"; done

# Non-normative check: the map must carry no RFC 2119 requirement language.
if grep -qE 'MUST|SHOULD|MAY NOT' "$map"; then
  fail=$((fail + 1)); echo "FAIL: map contains normative language"
else
  pass=$((pass + 1))
fi

# session-orient: silent without RIGGING.md, injects with it.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/proj"
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$repo/hooks/scripts/session-orient.sh")
if [ -z "$out" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: orient is silent without RIGGING.md"; fi
printf -- '- language: sh\n' > "$work/proj/RIGGING.md"
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$repo/hooks/scripts/session-orient.sh")
case "$out" in
  *"Shipshape Map"*"Deck state"*) pass=$((pass + 1)) ;;
  *) fail=$((fail + 1)); echo "FAIL: orient injects map and deck state with RIGGING.md" ;;
esac

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

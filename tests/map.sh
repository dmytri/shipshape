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

# The lean map names the component directories and delegates commands to
# `RIGGING.md`. It still names the durable artifacts, tags, and trace
# annotation, and every name it uses resolves to a skill.
for n in ".feature" "assets/**" "AGENTS.md" "RIGGING.md" "CAPTAIN.md" "watchbill.json"; do need "$n"; done
for n in "@captain" "@shipwright" "@invariant" "@exceptional-double" "@logic" "@sandbox"; do need "$n"; done
for n in "@planks(" ; do need "$n"; done

# Non-normative check: the map must carry no requirement language, in any
# case. A normative sentence in a structural map is a defect.
if grep -qiE '\b(must|should|shall|require)\b|MAY NOT' "$map"; then
  fail=$((fail + 1)); echo "FAIL: map contains normative language"
else
  pass=$((pass + 1))
fi

# Hook citations: every "(Article N: <name>.)" in a hook script must name
# the Nth Article heading in the core skill, so renumbering cannot drift.
core="$repo/skills/shipshape/SKILL.md"
cites=$(grep -ho '(Article [0-9]*: [^)]*)' "$repo"/hooks/scripts/*.sh | sort -u)
bad=""
while IFS= read -r c; do
  [ -z "$c" ] && continue
  n=$(printf '%s' "$c" | sed 's/(Article \([0-9]*\):.*/\1/')
  name=$(printf '%s' "$c" | sed 's/(Article [0-9]*: \(.*\))/\1/;s/\.$//' | tr 'A-Z' 'a-z')
  heading=$(sed -n "s/^$n\. \*\*\([^*]*\)\*\*.*/\1/p" "$core" | sed 's/\.$//' | tr 'A-Z' 'a-z')
  [ "$name" = "$heading" ] || bad="$bad [cite '$c' vs Article $n heading '$heading']"
done <<CITES
$cites
CITES
if [ -z "$bad" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: hook Article citations drifted:$bad"; fi

# session-orient: silent without RIGGING.md, injects with it.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/proj"
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$repo/hooks/scripts/session-orient.sh")
if [ -z "$out" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: orient is silent without RIGGING.md"; fi
printf -- '- language: sh\n' > "$work/proj/RIGGING.md"
out=$(printf '{"cwd":"%s"}' "$work/proj" | "$repo/hooks/scripts/session-orient.sh")
case "$out" in
  *"Specifications are durable"*"Deck state"*) pass=$((pass + 1)) ;;
  *) fail=$((fail + 1)); echo "FAIL: orient injects map and deck state with RIGGING.md" ;;
esac

echo "pass: $pass fail: $fail"
[ "$fail" -eq 0 ]

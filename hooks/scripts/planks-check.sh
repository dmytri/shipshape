#!/bin/sh
# Shipshape planks check. Stop hook.
#
# Enforces Article 17 from skills/shipshape/SKILL.md: "every production seam
# MUST have at least one @planks(...) annotation", and the Crew rule from
# skills/crew/SKILL.md: "MUST add or update @planks(...) annotations on every
# changed production seam." Doctrine lives in the skills; this script adds
# none.
#
# Role identity: Shipshape role agents declare "SHIPSHAPE-ROLE: <role>" in
# their system prompt. Sessions with no marker are the human-facing main
# loop; the check there stays with skill discipline.

payload=$(cat)

case "$payload" in
  *'"stop_hook_active":true'*|*'"stop_hook_active": true'*) exit 0 ;;
esac

transcript=$(printf '%s' "$payload" | sed -n 's/.*"transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
role=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  role=$(grep -m1 -o 'SHIPSHAPE-ROLE: [a-z]*' "$transcript" | cut -d' ' -f2)
fi
[ -z "$role" ] && exit 0

cwd=$(printf '%s' "$payload" | sed -n 's/.*"cwd":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$cwd" ] || cwd=$(pwd)
rig="$cwd/RIGGING.md"
[ -f "$rig" ] || exit 0
impl=$(sed -n 's/^- implementation:[[:space:]]*//p' "$rig" | head -1 | tr -d '`' | sed 's/[[:space:]]*$//;s|/$||')
[ -n "$impl" ] || exit 0

unplanked=""
for f in $(git -C "$cwd" diff --name-only HEAD 2>/dev/null); do
  case "$f" in
    "$impl"/*)
      [ -f "$cwd/$f" ] || continue
      grep -q '@planks(' "$cwd/$f" || unplanked="$unplanked $f"
      ;;
  esac
done

if [ -n "$unplanked" ]; then
  echo "Shipshape planks check: changed production files carry no @planks(...) annotation:$unplanked. Every production seam MUST have at least one @planks(...) annotation. Add the annotation or flag the seam." >&2
  exit 2
fi

exit 0

#!/bin/sh
# Shipshape planks check. Stop hook.
#
# Enforces Article 17 from skills/shipshape/SKILL.md: "every production seam
# MUST have at least one @planks(...) annotation", and the Crew rule from
# skills/crew/SKILL.md: "MUST add or update @planks(...) annotations on every
# changed production seam." Doctrine lives in the skills; this script adds
# none.
#
# Role identity: the runtime names the running agent in the hook payload
# as agent_type, such as "shipshape:crew". Payloads with no shipshape
# agent_type are the human-facing main loop or a foreign agent; custody
# does not apply there. Quoted mentions of the field inside tool_input
# arrive JSON-escaped and cannot match the unescaped top-level key.

payload=$(cat)

case "$payload" in
  *'"stop_hook_active":true'*|*'"stop_hook_active": true'*) exit 0 ;;
esac

role=$(printf '%s' "$payload" | sed -n 's/.*"agent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
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

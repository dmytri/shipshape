#!/bin/sh
# Shipshape planks check. SubagentStop hook.
#
# Enforces the "Every production seam is planked" Article from skills/shipshape/SKILL.md: "every production seam
# MUST have at least one @planks(...) annotation", and the Crew rule from
# skills/crew/SKILL.md: "MUST add or update @planks(...) annotations on every
# changed production seam." Doctrine lives in the skills; this script adds
# none.
#
# Role identity: the runtime names the finishing subagent in the hook
# payload as agent_type, such as "shipshape:crew". This runs on
# SubagentStop, which carries agent_type; the main-loop Stop event does
# not, so a role that assumes work in the main loop is out of reach here.
# Payloads with no shipshape agent_type are a foreign agent; custody does
# not apply there.

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
impl=$(sed -n 's/^- implementation:[[:space:]]*//p' "$rig" | head -1 | tr -d '`' | sed 's/[[:space:]]*$//')
[ -n "$impl" ] || exit 0

# implementation MAY list several comma-separated paths.
in_impl() {
  p="$1"; old="$IFS"; IFS=','
  for d in $impl; do
    d=$(printf '%s' "$d" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s|/$||')
    [ -z "$d" ] && continue
    case "$p" in "$d"/*) IFS="$old"; return 0 ;; esac
  done
  IFS="$old"; return 1
}

# Changed and new production files both count. diff omits untracked, so
# add the untracked-and-not-ignored list.
changed=$(git -C "$cwd" diff --name-only HEAD 2>/dev/null; git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null)
unplanked=""
for f in $changed; do
  if in_impl "$f"; then
    [ -f "$cwd/$f" ] || continue
    grep -q '@planks(' "$cwd/$f" || unplanked="$unplanked $f"
  fi
done

if [ -n "$unplanked" ]; then
  echo "Shipshape planks check: changed production files carry no @planks(...) annotation:$unplanked. Every production seam MUST have at least one @planks(...) annotation. Add the annotation or flag the seam." >&2
  exit 2
fi

exit 0

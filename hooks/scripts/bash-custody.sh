#!/bin/sh
# Shipshape command custody. PreToolUse guard for Bash.
#
# Enforces commit and outbound custody from the skills: Boatswain holds
# local commit custody (skills/boatswain/SKILL.md: "Commit locally in
# post-implementation mode only"; "Outbound is Captain-only. Do not push,
# tag, publish, release, or deploy.") and outbound requires explicit user
# approval through Captain (skills/captain/SKILL.md). Doctrine lives in the
# skills; this script adds none.
#
# Role identity: the runtime names the running agent in the hook payload
# as agent_type, such as "shipshape:crew". Payloads with no shipshape
# agent_type are the human-facing main loop or a foreign agent; custody
# does not apply there. Quoted mentions of the field inside tool_input
# arrive JSON-escaped and cannot match the unescaped top-level key.

payload=$(cat)

role=$(printf '%s' "$payload" | sed -n 's/.*"agent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
[ -z "$role" ] && exit 0

deny() {
  echo "Shipshape custody: $role MUST NOT run this command. $1" >&2
  exit 2
}

case "$role" in
  qm|crew|shipwright)
    case "$payload" in
      *CAPTAIN.md*) deny "CAPTAIN.md is Captain-only. Boatswain MAY read it; QM, Crew, and Shipwright derive everything from durable artifacts." ;;
    esac
    ;;
esac

case "$payload" in
  *"git push"*|*"git tag"*|*"npm publish"*|*"pnpm publish"*|*"yarn publish"*|*"gh release"*|*"gh pr create"*|*"vercel deploy"*|*"vercel --prod"*)
    deny "Outbound is Captain-only and requires explicit user approval."
    ;;
esac

case "$payload" in
  *"git commit"*)
    [ "$role" = "boatswain" ] || deny "Boatswain holds local commit custody."
    ;;
esac

exit 0

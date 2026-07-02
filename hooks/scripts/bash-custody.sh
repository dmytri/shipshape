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
# Role identity: Shipshape role agents declare "SHIPSHAPE-ROLE: <role>" in
# their system prompt. Sessions with no marker are the human-facing main
# loop; custody there stays with skill discipline and human oversight.

payload=$(cat)

transcript=$(printf '%s' "$payload" | sed -n 's/.*"transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
role=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  role=$(head -c 65536 "$transcript" | grep -m1 -o 'SHIPSHAPE-ROLE: [a-z]*' | cut -d' ' -f2)
fi
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

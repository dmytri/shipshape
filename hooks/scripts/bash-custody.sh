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

# Extract the command from tool_input, bounded to the first string so a
# mention in the description or in tool output cannot trigger custody.
# Normalize whitespace so flag-laden and double-spaced forms match.
command=$(printf '%s' "$payload" | sed -n 's/.*"command":[[:space:]]*"\([^"]*\)".*/\1/p')
norm=" $(printf '%s' "$command" | tr -s '[:space:]' ' ') "

case "$role" in
  qm|crew|shipwright)
    case "$command" in
      *CAPTAIN.md*) deny "CAPTAIN.md is Captain-only. Boatswain MAY read it; QM, Crew, and Shipwright derive everything from durable artifacts." ;;
    esac
    # The session transcript is discarded conversation context, never
    # product intent (Role transitions: "an internal role MUST NOT mine
    # it"). Block a command that names the transcript file. The path is
    # read from the payload, not the command, so it cannot be spoofed.
    transcript=$(printf '%s' "$payload" | sed -n 's/.*"transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
    if [ -n "$transcript" ]; then
      tbase=$(basename "$transcript")
      case "$command" in
        *"$tbase"*|*"$transcript"*) deny "Session transcript is discarded chat, not product intent. Derive everything from durable artifacts." ;;
      esac
    fi
    ;;
esac

# Outbound is Captain-only. Match the outbound verb even when git carries
# global flags before the subcommand, such as "git -C dir push".
case "$norm" in
  *" git push"*|*" git "*" push"*|*" git tag"*|*" git "*" tag "*|*" npm publish"*|*" pnpm publish"*|*" yarn publish"*|*" gh release"*|*" gh pr create"*|*" vercel deploy"*|*" vercel --prod"*)
    deny "Outbound is Captain-only and requires explicit user approval."
    ;;
esac

case "$norm" in
  *" git commit"*|*" git "*" commit"*)
    [ "$role" = "boatswain" ] || deny "Boatswain holds local commit custody."
    ;;
esac

exit 0

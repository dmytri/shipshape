#!/bin/sh
# Shipshape Captain reset nudge. PostToolUse reminder for Bash.
#
# Mechanizes the Captain context lifecycle (skills/shipshape/SKILL.md,
# "Captain context": Captain context is disposable and SHOULD reset at
# durable boundaries, after outbound). Fires after a main-loop Captain
# outbound command and nudges a reset for the next batch. It is a nudge,
# not a gate: it blocks nothing and the operator MAY continue. The
# hold-on-inaction lives in the Captain skill and the runtime, not here.
# Doctrine lives in the skills; this script adds none.

payload=$(cat)

# Only the human-facing main loop ships outbound; internal roles cannot
# push, so any shipshape agent_type means this is not a Captain outbound.
role=$(printf '%s' "$payload" | sed -n 's/.*"agent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
[ -n "$role" ] && exit 0

# Nudge only inside a Shipshape project.
cwd=$(printf '%s' "$payload" | sed -n 's/.*"cwd":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$cwd" ] || cwd=$(pwd)
[ -f "$cwd/RIGGING.md" ] || exit 0

# Bound extraction to the command string so a mention in the tool output
# cannot fire the nudge. Swap JSON-escaped quotes for a placeholder so a
# quoted argument cannot truncate the string and hide a later verb.
esc=$(printf '\001')
command=$(printf '%s' "$payload" | sed "s/\\\\\"/$esc/g" | sed -n 's/.*"command":[[:space:]]*"\([^"]*\)".*/\1/p' | tr "$esc" '"')
case "$command" in
  *"git push"*|*"git tag"*|*"npm publish"*|*"pnpm publish"*|*"yarn publish"*|*"gh release"*|*"vercel deploy"*|*"vercel --prod"*) : ;;
  *) exit 0 ;;
esac

printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"Batch shipped. Captain context is disposable and bounded to a batch. Offer the operator a fresh context for the next batch, rehydrated from durable artifacts and CAPTAIN.md; the operator MAY continue instead. Flush any pending intent to durable artifacts before a reset. (Captain context lifecycle.)"}}'
exit 0

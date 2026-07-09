#!/bin/sh
# Shipshape Captain reset nudge. PostToolUse reminder for Bash.
#
# Mechanizes the Captain context lifecycle (skills/captain/SKILL.md,
# "Context custody": Captain context is disposable and SHOULD reset at
# durable boundaries, after outbound). Fires after a main-loop Captain
# outbound command and nudges a reset for the next batch. It is a nudge,
# not a gate: it blocks nothing and the operator MAY continue. The
# hold-on-inaction lives in the Captain skill and the runtime, not here.
# Doctrine lives in the skills; this script adds none.

payload=$(cat)

# Only the human-facing main session ships outbound. The Outbound
# verification policy in skills/shipshape/SKILL.md states: "Outbound
# runs only in the human-facing main session, where the user's explicit
# approval is given". A spawned Captain reports outbound options and
# performs none, so any shipshape agent_type means this is not a
# Captain outbound.
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
outbound=0
case "$command" in
  *"npm publish"*|*"pnpm publish"*|*"yarn publish"*|*"gh release"*|*"vercel deploy"*|*"vercel --prod"*) outbound=1 ;;
esac
# Git outbound uses the same subcommand resolution as bash-custody: it
# resolves the true git verb past global flags, a path-prefixed binary
# such as /usr/bin/git, and a shell -c string, while "git stash push"
# and "git tag -l" stay silent.
if [ "$outbound" -eq 0 ]; then
  norm=" $(printf '%s' "$command" | tr -s '[:space:]' ' ') "
  gitsubs=$(printf '%s' "$norm" | awk '{
    for (i = 1; i <= NF; i++) {
      tok = $i; inq = 0
      if (i > 1 && $(i-1) == "-c" && sub(/^["'\'']/, "", tok)) inq = 1
      if (tok != "git" && tok !~ /\/git$/) continue
      j = i + 1
      while (j <= NF) {
        s = $j
        if (s == "-C" || s == "-c") { j += 2; continue }
        if (s ~ /^-/) { j++; continue }
        if (inq) sub(/["'\'']+$/, "", s)
        print s
        break
      }
    }
  }')
  for sub in $gitsubs; do
    case "$sub" in
      push) outbound=1 ;;
      tag)
        case "$norm" in
          *" tag -l"*|*" tag --list"*) : ;;
          *) outbound=1 ;;
        esac
        ;;
    esac
  done
fi
[ "$outbound" -eq 1 ] || exit 0

printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"Batch shipped. Captain context is disposable and bounded to a batch. Offer the operator a fresh context for the next batch, rehydrated from durable artifacts and CAPTAIN.md; the operator MAY continue instead. Flush any pending intent to durable artifacts before a reset. (Context custody.)"}}'
exit 0

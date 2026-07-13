#!/bin/sh
# Shipshape command custody. PreToolUse guard for Bash.
#
# Enforces commit and outbound custody from the skills: Boatswain holds
# local commit custody (skills/boatswain/SKILL.md: "Commit locally in
# the post-implementation job only"; "Outbound is Captain-only. Do not
# push, tag, publish, release, or deploy.") and outbound requires explicit
# user approval through Captain (skills/captain/SKILL.md). Doctrine lives
# in the skills; this script adds none.
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

# Extract the command from tool_input, bounded to the command string so a
# mention in the description or in tool output cannot trigger custody.
# JSON-escaped quotes are swapped for an unprintable placeholder before
# extraction so a quoted argument cannot truncate the string and hide a
# later verb, then restored. Normalize whitespace so flag-laden and
# double-spaced forms match.
esc=$(printf '\001')
command=$(printf '%s' "$payload" | sed "s/\\\\\"/$esc/g" | sed -n 's/.*"command":[[:space:]]*"\([^"]*\)".*/\1/p' | tr "$esc" '"')
norm=" $(printf '%s' "$command" | tr -s '[:space:]' ' ') "

case "$role" in
  qm|crew|boatswain|shipwright)
    # Access, not mention (skills/boatswain/SKILL.md): a CAPTAIN.md
    # inside a quoted string - an echoed label, a commit message - is
    # prose. A lone quoted path is unwrapped first so quoting cannot
    # hide a read, then every remaining quoted segment drops out. For
    # Boatswain the two content-blind staging forms (with git's global
    # flags) and bare metadata stats strip too; whatever still names
    # the file opens, searches, edits, or removes it, and is denied.
    notecheck=$(printf '%s' "$norm" | sed "s/[\"']CAPTAIN\\.md[\"']/CAPTAIN.md/g; s/'[^']*'//g; s/\"[^\"]*\"//g")
    if [ "$role" = "boatswain" ]; then
      notecheck=$(printf '%s' "$notecheck" | sed 's/:(exclude)CAPTAIN\.md//g; s/:!CAPTAIN\.md//g; s/git \(-C [^ ]* \)*add \(-- \)*CAPTAIN\.md//g; s/ls \(-[^ ]* \)*CAPTAIN\.md//g; s/stat \(-[^ ]* \)*CAPTAIN\.md//g; s/test -[a-z] CAPTAIN\.md//g')
    fi
    case "$notecheck" in
      *CAPTAIN.md*) deny "CAPTAIN.md is Captain-only. No role but Captain reads it; derive everything from durable artifacts." ;;
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

# Resolve every git subcommand in the command, skipping git's global
# flags such as "-C <dir>", so "git -C /x push" and "git status && git
# push" both resolve to their true subcommands while "git stash push"
# and "git log --grep push" stay innocent. A path-prefixed binary such
# as /usr/bin/git and a "command git" form resolve the same way. A
# token that opens a shell -c string sheds its leading quote, so
# sh -c "git push" resolves too; a quoted word anywhere else, such as
# an echo argument, keeps its quote and stays innocent.
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
    push) deny "Outbound is Captain-only and requires explicit user approval." ;;
    tag)
      case "$norm" in
        *" tag -l"*|*" tag --list"*) : ;;
        *) deny "Outbound is Captain-only and requires explicit user approval." ;;
      esac
      ;;
    commit)
      case "$role" in
        boatswain) : ;;
        captain)
          # Captain commits notes alone, pathspec-limited
          # (skills/captain/SKILL.md): git commit -m <msg> -- CAPTAIN.md
          # commits only the notes whatever else is staged.
          case "$norm" in
            *" -- CAPTAIN.md"*) : ;;
            *) deny "Boatswain holds local commit custody. Captain commits notes alone: git commit -m <msg> -- CAPTAIN.md." ;;
          esac
          ;;
        *) deny "Boatswain holds local commit custody." ;;
      esac
      ;;
  esac
done

case "$norm" in
  *" npm publish"*|*" pnpm publish"*|*" yarn publish"*|*" gh release"*|*" gh pr create"*|*" vercel deploy"*|*" vercel --prod"*)
    deny "Outbound is Captain-only and requires explicit user approval."
    ;;
esac

exit 0

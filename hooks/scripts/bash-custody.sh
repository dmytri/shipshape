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
    # Boatswain the content-blind staging and exclusion forms and bare
    # metadata stats strip too; whatever still names the file opens,
    # searches, edits, or removes it, and is denied.
    notecheck=$(printf '%s' "$norm" | sed "s/[\"']CAPTAIN\\.md[\"']/CAPTAIN.md/g; s/'[^']*'//g; s/\"[^\"]*\"//g")
    if [ "$role" = "boatswain" ]; then
      notecheck=$(printf '%s' "$notecheck" | sed 's/:(exclude)CAPTAIN\.md//g; s/:!CAPTAIN\.md//g; s/ls \(-[^ ]* \)*CAPTAIN\.md//g; s/stat \(-[^ ]* \)*CAPTAIN\.md//g; s/test -[a-z] CAPTAIN\.md//g')
      # Staging is not reading, and the path MAY ride among the other
      # paths of one git add pathspec list, so batching stays legal.
      # Split the command on its separators and strip the path only
      # inside a staging segment: a read elsewhere in the same compound
      # command keeps its CAPTAIN.md and is denied below.
      notecheck=$(printf '%s' "$notecheck" | awk '{
        n = split($0, seg, /[;&|]+/)
        out = ""
        for (i = 1; i <= n; i++) {
          s = seg[i]
          if (s ~ /(^|[ \/])git( +-[Cc] +[^ ]+)* +add( |$)/) gsub(/CAPTAIN\.md/, "", s)
          out = out " " s
        }
        print out
      }')
    fi
    case "$notecheck" in
      *CAPTAIN.md*) deny "CAPTAIN.md is Captain-only. No role but Captain reads it; derive everything from durable artifacts." ;;
    esac
    # Result-set custody, not mention custody. The notecheck above guards a
    # command that NAMES the notes; a routine search that names neither the
    # file nor any token still reads its content. The .ignore artifact covers
    # ripgrep and ag TRAVERSAL only, so deny the vectors that escape it and
    # leave the covered forms alone: GNU grep never reads .ignore at all, an
    # rg ignore-override flag outranks it, and a shell glob in the path list
    # expands to explicit paths that no ignore file can exclude.
    searchfault=$(printf '%s' "$norm" | awk '{
      for (i = 1; i <= NF; i++) {
        t = $i
        sub(/^["'\'']/, "", t); sub(/["'\'']+$/, "", t)
        if (t != "grep" && t !~ /\/grep$/ && t != "egrep" && t != "fgrep" &&
            t != "rg" && t !~ /\/rg$/ && t != "ag" && t != "ack") continue
        isgrep = (t ~ /grep$/)
        rec = 0; ovr = 0; glb = 0
        for (j = i + 1; j <= NF; j++) {
          a = $j
          if (a ~ /^[;&|]/) break
          sub(/^["'\'']/, "", a); sub(/["'\'']+$/, "", a)
          if (a !~ /^--/ && a ~ /^-[a-zA-Z]*[rR]/) rec = 1
          if (a == "--recursive" || a == "--dereference-recursive") rec = 1
          if (a == "-g" || a == "--glob" || a == "--no-ignore" ||
              a == "--no-ignore-vcs" || a == "-u" || a == "--unrestricted") ovr = 1
          if (a !~ /^-/ && a ~ /[*?[]/) glb = 1
        }
        if (isgrep && rec) { print "recursive grep, which never reads the ignore artifact"; exit }
        if (!isgrep && ovr) { print "an ignore-override flag, which outranks the ignore artifact"; exit }
        if (glb) { print "a shell glob in the path list, which expands to explicit paths the ignore artifact cannot exclude"; exit }
      }
    }')
    if [ -n "$searchfault" ]; then
      deny "That search can surface the Captain-only notes through $searchfault. Use \`rg <pattern>\`, \`rg -t md <pattern>\`, or \`rg --hidden <pattern>\`, which honour the ignore artifact."
    fi

    # Same result-set custody, git's readers. A diff or a history read prints the
    # content of every changed file: it reads no ignore artifact, and it names
    # nothing, so the notecheck above cannot see it either. Roles genuinely need
    # the role-advanced diff, so guard the form rather than the command: a
    # pathspec excluding the notes passes, an unscoped read does not. `--stat`,
    # `--name-only` and `--name-status` print no content and stay allowed.
    gitfault=$(printf '%s' "$norm" | awk '{
      for (i = 1; i <= NF; i++) {
        t = $i
        sub(/^["'\'']/, "", t); sub(/["'\'']+$/, "", t)
        if (t != "git" && t !~ /\/git$/) continue
        scmd = ""; patch = 0; content = 0; excluded = 0; nofile = 0
        for (j = i + 1; j <= NF; j++) {
          a = $j
          if (a ~ /^[;&|]/) break
          sub(/^["'\'']/, "", a); sub(/["'\'']+$/, "", a)
          if (a == "-C" || a == "-c") { j++; continue }
          if (scmd == "" && a !~ /^-/) { scmd = a; continue }
          if (a == "-p" || a == "--patch" || a == "-u") patch = 1
          if (a == "--stat" || a == "--name-only" || a == "--name-status" ||
              a == "--numstat" || a == "--shortstat" || a == "--quiet") nofile = 1
          if (a ~ /CAPTAIN\.md$/ && a ~ /^:(\(exclude\)|!)/) excluded = 1
        }
        if (scmd == "diff" || scmd == "show") content = 1
        if ((scmd == "log" || scmd == "stash") && patch) content = 1
        if (content && !nofile && !excluded) {
          print scmd; exit
        }
      }
    }')
    if [ -n "$gitfault" ]; then
      deny "\`git $gitfault\` prints the content of every changed file, including the Captain-only notes, and names nothing for this guard to catch. Carry the exclusion in the command: \`git diff <base> -- . ':!CAPTAIN.md'\`, the same pathspec on \`git show\`, \`git log -p\` and \`git stash show -p\`, or a content-free form such as \`--stat\` or \`--name-only\`."
    fi
    # A loop that re-checks a process table is a busy-wait, not a signal, and the
    # Wait policy names it: it spends the turn to learn what the exit already
    # reports. It also matches the WRONG process. The predicate is a name, and a
    # name is not owned: a concurrent session running the same runner keeps it
    # true forever, so the loop never terminates and outlives the turn that
    # started it. Live-proven twice in this project - once operator-side, once by
    # a role whose loop was still spinning against another checkout's suite after
    # the role had reported and stopped, where no stop guard could reach it
    # because the turn had ended cleanly.
    #
    # Guard the LOOP, not the command: a bare `pgrep` or `ps` that reports once is
    # a legitimate read and passes. Only a loop whose continuation depends on a
    # process query is denied.
    waitfault=$(printf '%s' "$norm" | awk '{
      loop = 0
      for (i = 1; i <= NF; i++) {
        t = $i
        sub(/^["'"'"']/, "", t); sub(/["'"'"']+$/, "", t)
        if (t == "while" || t == "until") { loop = 1; continue }
        if (t == "do" || t == ";") continue
        if (loop && (t == "pgrep" || t == "ps" || t ~ /\/pgrep$/ || t ~ /\/ps$/)) { print t; exit }
        if (loop && t == "done") loop = 0
      }
    }')
    if [ -n "$waitfault" ]; then
      deny "That waits on a process name, which is a busy-wait and not a signal, and a process name is not owned: another session running the same command keeps the condition true and the loop never ends. Wait on the run's own exit, or on its output file read to the summary line. Where the run outlasts the foreground budget, raise the budget with a timeout that covers it."
    fi

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
          # commits only the notes whatever else is staged. On a
          # repository with no commits the initial commit is Captain's
          # own bootstrap action (skills/captain/SKILL.md): an unborn
          # HEAD carries no role-advanced work for custody to protect.
          # The cwd is read from the payload, not the command, so it
          # cannot be spoofed; outside a work tree the deny stands.
          case "$norm" in
            *" -- CAPTAIN.md"*) : ;;
            *)
              cwd=$(printf '%s' "$payload" | sed -n 's/.*"cwd":[[:space:]]*"\([^"]*\)".*/\1/p')
              if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 && ! git -C "$cwd" rev-parse -q --verify HEAD >/dev/null 2>&1; then
                :
              else
                deny "Boatswain holds local commit custody. Captain commits notes alone: git commit -m <msg> -- CAPTAIN.md."
              fi
              ;;
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

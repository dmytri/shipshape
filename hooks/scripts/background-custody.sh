#!/bin/sh
# Shipshape background-work custody. SubagentStop guard.
#
# The fault: a role ends its turn while a backgrounded command's output has
# never been read. A background completion cannot resume a finished agent
# chain, so the turn deadlocks silently and only an operator can rescue it
# (pilot #2 2026-07-13; efficiency battery 0.13.33 tw13, 8m26s dead).
#
# This guard blocks the STOP, not the command. It denies no command and so
# breaks no legitimate command, which is the failure mode a PreToolUse
# wait-class deny was warned for (dk's whack-a-mole disposition 2026-07-15,
# pilot-#3-proven). It also fires on the observed fault shape, which that
# deny would not: the 0.13.33 reproduction ran NO wait command at all - it
# ToolSearched for Monitor, never called it, ran `true`, and stopped.
#
# Enforces the Hand-off custody rule from skills/shipshape/SKILL.md: "A role
# never ends its turn holding work that cannot resume it: not a background
# command, a notification, or a timer." That section also asks a runtime to
# carry the rule as machinery. Doctrine lives in the skills; this adds none.
#
# Role identity: the runtime names the finishing subagent as agent_type.
# The main-loop Stop event carries none, so the operator seat is out of
# reach here, as with planks-check.sh.

payload=$(cat)

# Re-entrancy: a blocked stop re-enters this hook. Never block twice.
case "$payload" in
  *'"stop_hook_active":true'*|*'"stop_hook_active": true'*) exit 0 ;;
esac

role=$(printf '%s' "$payload" | sed -n 's/.*"agent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
[ -z "$role" ] && exit 0

# The FINISHING AGENT'S OWN transcript, never the session's. The payload carries
# both: "transcript_path" is the parent session file, which aggregates every
# agent's lines and the operator's own, and "agent_transcript_path" is this
# subagent's. Reading the session file is wrong in both directions, live-proven
# 2026-07-21: two plugin legs were blocked naming a task neither had launched -
# an operator command that MINED a sibling's transcript echoed that sibling's
# launch announcement into the session file, and the guard read it as the
# finishing role's own - while each leg's real stall sat unseen in its own
# transcript. Any text that quotes a launch announcement poisons the session
# file; the agent's own transcript is the only sound input. Fall back to
# transcript_path only where the runtime supplies no agent path.
transcript=$(printf '%s' "$payload" | sed -n 's/.*"agent_transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$transcript" ] || transcript=$(printf '%s' "$payload" | sed -n 's/.*"transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

# Shell tasks the runtime reports STILL RUNNING at this stop. background_tasks is
# session-wide, so it never attributes on its own - it is intersected below with
# what this agent's own transcript shows it launched. Subagent entries are
# excluded: an Agent child's report resumes its caller, per Hand-off custody.
running=$(printf '%s' "$payload" \
  | tr '{' '\n' \
  | sed -n 's/.*"id":[[:space:]]*"\([A-Za-z0-9_-]*\)"[^}]*"type":[[:space:]]*"shell"[^}]*"status":[[:space:]]*"running".*/\1/p')

# One JSONL event per line, so line order is event order and no JSON parse
# is needed: the task id is a distinctive literal token.
#
# A launch line is a tool_result announcing that a command went to the
# background; it names the output file as tasks/<id>.output. An Agent
# spawn is NOT a launch - its result carries "agentId:", never a task
# output path - because an Agent child's completion DOES resume its
# parent through the task-notification, so a turn ending on a live Agent
# child self-heals (observed 2026-07-19 tw13) and is not this fault.
#
# Consumption is any later line naming that output PATH: a Read of the
# output file, a cat/tail of it, or the completion notification itself.
# The path, not the bare id: a role that ends its turn saying "waiting for
# background task <id>" names the id and consumes nothing, and matching the
# bare id let exactly that stop through (pilot #7 2026-07-21, QM stalled on
# its own suite run and this guard passed it - the guard was defeated by the
# one sentence that describes the fault). Every real consumption names the
# path; prose about waiting does not.
#
# A read while the command is STILL RUNNING is not consumption either. Reading an
# output file part-way names the path and says nothing about how the run ended,
# so the turn still ends holding live work - live-proven 2026-07-21, where a leg
# read its own sweep's output mid-flight, saw three early failures, ended its
# turn, and deadlocked with this guard satisfied. Any task the runtime still
# reports running is unfinished by the runtime's own account, which outranks
# what the transcript appears to show. This is the check-precedence rule: a run
# judged complete by eye is unchecked.
unconsumed=$(awk -v running="$running" '
  BEGIN { n = split(running, r, "\n"); for (i = 1; i <= n; i++) if (r[i] != "") live[r[i]] = 1 }
  /moved to the background|running in background|is being written to/ {
    s = $0
    while (match(s, /tasks\/[A-Za-z0-9_-]+\.output/)) {
      tok = substr(s, RSTART + 6, RLENGTH - 13)
      if (!(tok in launched)) { launched[tok] = NR }
      s = substr(s, RSTART + RLENGTH)
    }
    next
  }
  {
    for (tok in launched) {
      if (launched[tok] < NR && index($0, "tasks/" tok ".output") && !(tok in live)) delete launched[tok]
    }
  }
  END {
    for (tok in launched) printf "%s ", tok
  }
' "$transcript")

if [ -n "$unconsumed" ]; then
  echo "Shipshape background custody: this turn backgrounded work that is still unfinished or unread (task$(printf '%s' "$unconsumed" | tr -s ' ' | sed 's/ $//' | sed 's/^/ /')). A background completion cannot resume a finished turn, so ending here deadlocks it silently. Read the output file to its summary line - a part-way read of a run still in flight is not evidence - then end the turn. Where the run is the reason to background at all, prefer keeping it in the foreground under a timeout that covers it. Wait on output files, never on process names." >&2
  exit 2
fi

exit 0

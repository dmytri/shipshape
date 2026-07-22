#!/bin/sh
# Shipshape write custody. PreToolUse guard for Edit/Write/MultiEdit/NotebookEdit.
#
# Enforces the "Write scopes are strict" Article from skills/shipshape/SKILL.md
# and the role contracts in skills/captain, skills/qm, skills/crew,
# skills/boatswain, and skills/shipwright. Doctrine lives in the skills;
# this script adds none.
# Delete this plugin and nothing is lost but enforcement.
#
# Role identity: the runtime names the running agent in the hook payload
# as agent_type, such as "shipshape:crew". Payloads with no shipshape
# agent_type are the human-facing main loop or a foreign agent; custody
# does not apply there. Quoted mentions of the field inside tool_input
# arrive JSON-escaped and cannot match the unescaped top-level key.

payload=$(cat)

role=$(printf '%s' "$payload" | sed -n 's/.*"agent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
[ -z "$role" ] && exit 0

file_path=$(printf '%s' "$payload" | sed -n 's/.*"file_path":[[:space:]]*"\([^"]*\)".*/\1/p')
# NotebookEdit carries the target as notebook_path, not file_path.
[ -z "$file_path" ] && file_path=$(printf '%s' "$payload" | sed -n 's/.*"notebook_path":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$file_path" ] && exit 0

# Resolve "." and ".." path segments lexically so a traversal such as
# src/../elsewhere/x.ts cannot slip past a directory check. Pure sh
# with no filesystem calls: a clean path passes through unchanged and
# symlink resolution stays out of scope.
normalize() {
  np_in="$1"; np_out=""; np_abs=0
  case "$np_in" in /*) np_abs=1 ;; esac
  np_old="$IFS"; IFS=/
  set -f
  set -- $np_in
  set +f
  IFS="$np_old"
  for np_seg in "$@"; do
    case "$np_seg" in
      ''|.) ;;
      ..)
        case "$np_out" in
          ''|..|*/..)
            if [ -n "$np_out" ]; then np_out="$np_out/.."
            elif [ "$np_abs" -eq 0 ]; then np_out=".."
            fi
            ;;
          */*) np_out="${np_out%/*}" ;;
          *) np_out="" ;;
        esac
        ;;
      *)
        if [ -n "$np_out" ]; then np_out="$np_out/$np_seg"; else np_out="$np_seg"; fi
        ;;
    esac
  done
  if [ "$np_abs" -eq 1 ]; then printf '/%s' "$np_out"; else printf '%s' "$np_out"; fi
}

cwd=$(printf '%s' "$payload" | sed -n 's/.*"cwd":[[:space:]]*"\([^"]*\)".*/\1/p')
file_path=$(normalize "$file_path")
base=$(basename "$file_path")

# The project root is found by walking UP FROM THE FILE BEING WRITTEN, not from
# the session's cwd. A role's cwd is the session directory, which is not the
# project root whenever the role works in a tree the session did not start in -
# a scaffolded project, a second checkout, a monorepo package. Resolving from cwd
# meant RIGGING.md was not found, every directory value came back empty, no
# directory check could match, and custody PASSED EVERY WRITE SILENTLY.
# Live-proven 2026-07-22: four QM legs wrote production code with no deny, while
# bash-custody kept firing in the same legs because its rules are path-blind, so
# custody looked alive. A guard that cannot find the project must not conclude
# that the write is legal.
root=""
d=$(dirname "$file_path")
while [ -n "$d" ] && [ "$d" != "/" ] && [ "$d" != "." ]; do
  if [ -f "$d/RIGGING.md" ]; then root="$d"; break; fi
  d=$(dirname "$d")
done
[ -z "$root" ] && [ -n "$cwd" ] && [ -f "$cwd/RIGGING.md" ] && root=$(normalize "$cwd")
[ -z "$root" ] && [ -f "RIGGING.md" ] && root=$(pwd)

rel="$file_path"
[ -n "$root" ] && rel="${file_path#"$root"/}"

deny() {
  echo "Shipshape custody: $role MUST NOT write $rel. $1 (Article: Write scopes are strict.)" >&2
  exit 2
}

# Project directories from RIGGING.md (## Directories). Values are optional;
# absent values simply narrow what custody can check.
rigdir=""
[ -n "$root" ] && [ -f "$root/RIGGING.md" ] && rigdir="$root/RIGGING.md"
impl="" specs="" verif="" assets="" scant=""
if [ -n "$rigdir" ]; then
  impl=$(sed -n 's/^- implementation:[[:space:]]*//p' "$rigdir" | tr -d '`' | sed 's|[[:space:]]*/*$||')
  specs=$(sed -n 's/^- specs:[[:space:]]*//p' "$rigdir" | tr -d '`' | sed 's|[[:space:]]*/*$||')
  verif=$(sed -n 's/^- verification:[[:space:]]*//p' "$rigdir" | tr -d '`' | sed 's|[[:space:]]*/*$||')
  assets=$(sed -n 's/^- assets:[[:space:]]*//p' "$rigdir" | tr -d '`' | sed 's|[[:space:]]*/*$||')
  scant=$(sed -n 's/^- scantlings:[[:space:]]*//p' "$rigdir" | tr -d '`' | sed 's|[[:space:]]*/*$||')
fi

# in_dirs <rel> <newline-separated dirs> -> exit status 0 when rel is inside any.
# A dir MAY be a glob such as packages/*/src, where * matches one path segment.
in_dirs() {
  p="$1"
  dirs="$2"
  old_ifs="$IFS"; IFS='
'
  set -f
  for d in $dirs; do
    [ -z "$d" ] && continue
    case "$p" in
      $d/*|$d) set +f; IFS="$old_ifs"; return 0 ;;
    esac
  done
  set +f; IFS="$old_ifs"; return 1
}

case "$role" in
  captain)
    # skills/captain/SKILL.md Role contract: "Write only Captain-custodied
    # durable artifacts", meaning .feature specs, referenced assets/**,
    # CAPTAIN.md, and optional watchbill.json, and "MUST NOT write
    # production code or verification, except for the perturbation rule
    # below." The perturbation exception lands in production code and the
    # tooling-value exception lands in RIGGING.md; neither is mechanically
    # decidable here, so those paths stay open. Verification carries no
    # such exception, so a verification directory derived from RIGGING.md
    # is denied.
    #
    # Artifact kind outranks directory: a .feature file is a Captain spec
    # wherever it sits, exactly as the qm and crew branches below hold. A
    # verification value MAY contain the specs directory, as in a
    # Cucumber-conventional layout whose step definitions live under
    # features/, so a directory check alone would deny the Captain their
    # own spec.
    case "$base" in *.feature) exit 0 ;; esac
    [ -n "$verif" ] && in_dirs "$rel" "$verif" && deny "MUST NOT write production code or verification, except for the perturbation rule below."
    ;;
  qm)
    # skills/qm/SKILL.md: "Write only verification: tests, fixtures, step
    # definitions, harness, test support." "MUST NOT read CAPTAIN.md."
    case "$base" in
      *.feature) deny "Captain writes specs." ;;
      CAPTAIN.md|watchbill.json|AGENTS.md|RIGGING.md) deny "Captain-custodied or configuration artifact." ;;
    esac
    [ -n "$impl" ] && in_dirs "$rel" "$impl" && deny "Production code belongs to Crew."
    [ -n "$assets" ] && in_dirs "$rel" "$assets" && deny "Assets are Captain-custodied."
    [ -n "$scant" ] && in_dirs "$rel" "$scant" && deny "Scantlings are Captain-custodied."
    ;;
  crew)
    # skills/crew/SKILL.md: "Write production code only. No specs, tests,
    # fixtures, harness, assets, or Captain notes."
    case "$base" in
      *.feature) deny "Captain writes specs." ;;
      CAPTAIN.md|watchbill.json|AGENTS.md|RIGGING.md) deny "Captain-custodied or configuration artifact." ;;
    esac
    [ -n "$verif" ] && in_dirs "$rel" "$verif" && deny "Verification belongs to QM."
    [ -n "$specs" ] && in_dirs "$rel" "$specs" && deny "Specs belong to Captain."
    [ -n "$assets" ] && in_dirs "$rel" "$assets" && deny "Assets are Captain-custodied."
    [ -n "$scant" ] && in_dirs "$rel" "$scant" && deny "Scantlings are Captain-custodied."
    ;;
  boatswain)
    # skills/boatswain/SKILL.md: "Captain trims their own notes; Boatswain
    # MUST NOT read or edit CAPTAIN.md."
    case "$base" in
      CAPTAIN.md) deny "Captain trims their own notes; Boatswain MUST NOT edit them." ;;
    esac
    ;;
  shipwright)
    # skills/shipwright/SKILL.md: "Never change production-code behaviour,
    # verification, assets/, CAPTAIN.md, or watchbill.json."
    case "$base" in
      CAPTAIN.md|watchbill.json) deny "Shipwright never changes Captain-custodied working artifacts." ;;
    esac
    # Artifact kind outranks directory, as in the captain branch above:
    # Shipwright writes @captain scenario skeletons under the specs
    # directory, and a verification value that contains the specs directory
    # MUST NOT deny them.
    case "$base" in *.feature) exit 0 ;; esac
    [ -n "$verif" ] && in_dirs "$rel" "$verif" && deny "Shipwright never changes verification."
    [ -n "$assets" ] && in_dirs "$rel" "$assets" && deny "Shipwright never changes assets."
    [ -n "$scant" ] && in_dirs "$rel" "$scant" && deny "Shipwright never authors a project-owned scantling."
    ;;
esac

exit 0

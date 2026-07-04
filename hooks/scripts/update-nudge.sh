#!/bin/sh
# Shipshape update nudge. SessionStart hook.
#
# Compares the installed plugin version against main and emits one line
# when a newer release exists. Nudge only: it applies nothing and blocks
# nothing. An update is a voyage boundary, a Captain decision, so the
# human or Captain applies it at a clean boundary. Fail-silent: offline,
# timeout, missing tooling, or a version tie stays quiet. At most one
# network check per day. Doctrine lives in the skills; this script adds
# none.

root=$(cd "$(dirname "$0")/../.." && pwd)
manifest="$root/.plugin/plugin.json"
[ -f "$manifest" ] || exit 0

ver() {
  sed -n 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1
}

installed=$(ver < "$manifest")
[ -n "$installed" ] || exit 0

# A test or an operator MAY point the remote at a local manifest. This is
# the network-free path and the verification seam.
remote_src="${SHIPSHAPE_REMOTE_MANIFEST:-}"
if [ -n "$remote_src" ]; then
  [ -f "$remote_src" ] || exit 0
  remote=$(ver < "$remote_src")
else
  # Throttle the network path to one check per day.
  marker="${TMPDIR:-/tmp}/shipshape-update-check"
  if [ -f "$marker" ] && [ -z "$(find "$marker" -mmin +1440 2>/dev/null)" ]; then
    exit 0
  fi
  : > "$marker" 2>/dev/null || true

  url="https://raw.githubusercontent.com/dmytri/shipshape/main/.plugin/plugin.json"
  if command -v curl >/dev/null 2>&1; then
    remote=$(curl -fsS --max-time 2 "$url" 2>/dev/null | ver)
  elif command -v wget >/dev/null 2>&1; then
    remote=$(wget -q -T 2 -O - "$url" 2>/dev/null | ver)
  else
    exit 0
  fi
fi
[ -n "$remote" ] || exit 0

# Nudge only when remote is strictly newer by version sort.
[ "$installed" = "$remote" ] && exit 0
newest=$(printf '%s\n%s\n' "$installed" "$remote" | sort -V | tail -n1)
[ "$newest" = "$remote" ] || exit 0

echo "Shipshape $remote available, $installed installed. Update at a voyage boundary with npx plugins update or npx skills update. This is a Captain decision, not automatic."
exit 0

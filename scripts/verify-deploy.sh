#!/usr/bin/env bash
# verify-deploy.sh <build-dir> <live-dir>
#
# The fix: compare content hashes, not sizes. Exits non-zero and names every
# file whose "live" content doesn't actually match the build artifact -
# closing exactly the gap sync-size-only.sh's size-only comparison leaves
# open. Same pattern a real deploy-verification step would run post-sync.
#
# Scope, disclosed rather than silently assumed: this only checks that every
# file in <build-dir> is correctly live, the same "artifact vs live" design
# a real post-deploy check would run. It does not detect orphaned files that
# exist under <live-dir> but were removed from <build-dir> - a known,
# deliberately out-of-scope residual gap, not an oversight.
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: verify-deploy.sh <build-dir> <live-dir>" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

# See sync-size-only.sh for why trailing slashes are stripped here too.
build="${1%/}"
live="${2%/}"

if [ ! -d "$build" ]; then
  echo "error: build directory not found: $build" >&2
  exit 1
fi
if [ ! -d "$live" ]; then
  echo "error: live directory not found: $live" >&2
  exit 1
fi
require_no_overlap "$build" "$live"

if [ -z "$(find "$build" -type f -print -quit)" ]; then
  echo "error: build directory is empty, nothing to verify: $build" >&2
  exit 1
fi

status=0

# Disclosed limitation, not fixed: `find -type f` does not follow symlinks -
# see sync-size-only.sh's matching note.
while IFS= read -r -d '' f; do
  rel="${f#"$build"/}"
  live_f="$live/$rel"

  if [ ! -f "$live_f" ]; then
    echo "STALE (missing on live): $rel"
    status=1
    continue
  fi

  if [ "$(file_hash "$f")" != "$(file_hash "$live_f")" ]; then
    echo "STALE (content mismatch): $rel"
    status=1
  else
    echo "OK: $rel"
  fi
done < <(find "$build" -type f -print0)

exit "$status"

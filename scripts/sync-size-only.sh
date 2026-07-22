#!/usr/bin/env bash
# sync-size-only.sh <src-dir> <dest-dir>
#
# Mirrors the real comparison logic behind `aws s3 sync --size-only`: a file
# is considered "unchanged" and skipped whenever its size matches the
# destination's, even if the actual bytes differ. This is the bug - a
# same-byte-length content change never gets uploaded.
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: sync-size-only.sh <src-dir> <dest-dir>" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

# Strip any trailing slash - "${src}/" would otherwise make the "${f#"$src"/}"
# prefix-strip below try to match a double slash against find's single-slash
# output, silently fail to strip anything, and nest files under the entire
# absolute source path instead of their real relative path.
src="${1%/}"
dest="${2%/}"

if [ ! -d "$src" ]; then
  echo "error: source directory not found: $src" >&2
  exit 1
fi
mkdir -p "$dest"
require_no_overlap "$src" "$dest"

# Disclosed limitation, not fixed: `find -type f` does not follow symlinks,
# so a symlinked asset in $src is silently skipped by both this script and
# verify-deploy.sh. Out of scope here - it's a different failure mode than
# the one this repo demonstrates.
while IFS= read -r -d '' f; do
  rel="${f#"$src"/}"
  dest_f="$dest/$rel"

  if [ -f "$dest_f" ] && [ "$(file_size "$f")" = "$(file_size "$dest_f")" ]; then
    echo "skip (size unchanged): $rel"
    continue
  fi

  mkdir -p "$(dirname "$dest_f")"
  cp "$f" "$dest_f"
  echo "upload: $rel"
done < <(find "$src" -type f -print0)

#!/usr/bin/env bash
# Runs the full two-day scenario and asserts both properties empirically -
# this is a characterization test, not a demo: it fails loudly if either
# the bug or the fix stops reproducing.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

build="$work_dir/build"
live="$work_dir/live"

echo "=== Day 1: first deploy ==="
./scripts/render.sh "16 July 2026" "$build"
./scripts/sync-size-only.sh "$build" "$live"
echo

echo "=== Day 2: a same-length date change ships ==="
./scripts/render.sh "17 July 2026" "$build"
./scripts/sync-size-only.sh "$build" "$live"
echo

echo "=== Assertion 1: the bug is real - live still says '16 July 2026' ==="
if grep -q "16 July 2026" "$live/index.html"; then
  echo "CONFIRMED: live/index.html is stale (size-only sync skipped the change)."
else
  echo "FAIL: expected the size-only sync bug to reproduce, but live content updated."
  exit 1
fi
echo

echo "=== Assertion 2: content-hash verification catches it ==="
# Capture output separately from exit status: a non-zero exit alone could
# also mean the script crashed, a hash tool was missing, or some unrelated
# bug, none of which is "correctly detected the staleness." Require both
# the specific STALE line AND a non-zero exit before calling this confirmed.
verify_output="$(./scripts/verify-deploy.sh "$build" "$live" 2>&1)" && verify_exit=0 || verify_exit=$?
echo "$verify_output"
if [ "$verify_exit" -eq 0 ]; then
  echo "FAIL: expected verify-deploy.sh to detect the staleness, but it reported OK."
  exit 1
elif ! grep -q "STALE (content mismatch): index.html" <<< "$verify_output"; then
  echo "FAIL: verify-deploy.sh exited non-zero, but not for the reason this test expects."
  exit 1
else
  echo "CONFIRMED: verify-deploy.sh correctly failed and named the stale file."
fi

echo
echo "Both assertions passed: the bug reproduces, and the fix catches it."

# Shared helpers, portable across macOS (BSD stat/shasum) and Linux (GNU
# stat/sha256sum) CI runners. Sourced, not executed directly.

file_size() {
  stat -f%z "$1" 2>/dev/null || stat -c%s "$1"
}

file_hash() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

# require_no_overlap <a> <b>: error out if one of two already-existing
# directories contains the other. Guards against a swapped/misused argument
# turning a sync or verify pass into a script copying or comparing its own
# output back into the tree it's traversing.
require_no_overlap() {
  local a b
  a="$(cd "$1" && pwd -P)"
  b="$(cd "$2" && pwd -P)"
  case "$a/" in
    "$b/") echo "error: source and destination are the same directory: $a" >&2; exit 1 ;;
    "$b"/*) echo "error: source ($a) is inside destination ($b)" >&2; exit 1 ;;
  esac
  case "$b/" in
    "$a"/*) echo "error: destination ($b) is inside source ($a)" >&2; exit 1 ;;
  esac
}

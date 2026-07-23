#!/usr/bin/env bash
# render.sh <date-string> <out-dir>
# Renders site/index.html.tmpl with <date-string> substituted for {{DATE}},
# the same way a static-site generator stamps a build timestamp into a
# footer template.
#
# Uses bash's own parameter-expansion replacement, not sed, because the
# caller-supplied date string is untrusted-shaped input and sed's
# replacement side treats `&` and the delimiter character specially - a `/`
# in the date crashes the script, an `&` gets expanded into the whole
# matched pattern. Bash's ${var//pattern/replacement} avoids the delimiter
# problem entirely, but empirically (verified directly against bash 5.3,
# not assumed) it ALSO treats a literal `&` in the replacement as "the
# matched text," the same sed-ism this rewrite exists to avoid - so `&` and
# `\` are escaped first, below, rather than trusted to pass through literally.
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: render.sh <date-string> <out-dir>" >&2
  exit 1
fi

date_str="$1"
out_dir="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template="$script_dir/../site/index.html.tmpl"

if [ ! -f "$template" ]; then
  echo "error: template not found: $template" >&2
  exit 1
fi

mkdir -p "$out_dir"
content="$(cat "$template")"
# Escape backslash first, then ampersand - both are special in a bash
# parameter-expansion replacement, and escaping ampersand first would
# double-escape the backslash that introduces its own escape.
escaped_date="${date_str//\\/\\\\}"
escaped_date="${escaped_date//&/\\&}"
printf '%s\n' "${content//\{\{DATE\}\}/$escaped_date}" > "$out_dir/index.html"

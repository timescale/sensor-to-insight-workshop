#!/usr/bin/env bash
#
# Runs SQL from the editor through `tiger db query`. Called by the
# "Run SQL with Tiger CLI" task in .vscode/tasks.json (Ctrl+Shift+B).
#
# The selected text arrives in $SQL_SELECTION (an environment variable, so quotes,
# semicolons and newlines in the SQL never pass through shell parsing). With
# nothing selected, the whole file ($1) runs instead.

set -euo pipefail

file="${1:-}"

if [[ -n "${SQL_SELECTION//[[:space:]]/}" ]]; then
  tmp="$(mktemp --suffix=.sql)"
  trap 'rm -f "$tmp"' EXIT
  printf '%s\n' "$SQL_SELECTION" > "$tmp"
  echo "==> Running selection"
  tiger db query -f "$tmp"
elif [[ -n "$file" ]]; then
  echo "==> No selection; running $(basename "$file")"
  tiger db query -f "$file"
else
  echo "Nothing to run: select some SQL or open a .sql file." >&2
  exit 1
fi

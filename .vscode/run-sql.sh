#!/usr/bin/env bash
#
# Runs SQL from the editor through `tiger db query`. Called by the
# "Run SQL with Tiger CLI" task in .vscode/tasks.json (Ctrl+Shift+B).
#
# The selected text arrives in $SQL_SELECTION (an environment variable, so quotes,
# semicolons and newlines in the SQL never pass through shell parsing). With
# nothing selected, the whole file ($1) runs instead.
#
# Prints how long the run took. That's wall-clock time, so it includes starting
# the CLI and the round trip to Tiger Cloud, not just the query itself.

set -euo pipefail

file="${1:-}"

if [[ -n "${SQL_SELECTION//[[:space:]]/}" ]]; then
  sql_file="$(mktemp --suffix=.sql)"
  trap 'rm -f "$sql_file"' EXIT
  printf '%s\n' "$SQL_SELECTION" > "$sql_file"
  echo "==> Running selection"
elif [[ -n "$file" ]]; then
  sql_file="$file"
  echo "==> No selection; running $(basename "$file")"
else
  echo "Nothing to run: select some SQL or open a .sql file." >&2
  exit 1
fi

start_ns=$(date +%s%N)
status=0
tiger db query -f "$sql_file" || status=$?
elapsed_ms=$(( ($(date +%s%N) - start_ns) / 1000000 ))

printf '==> Took %d.%03ds\n' $(( elapsed_ms / 1000 )) $(( elapsed_ms % 1000 ))
exit "$status"

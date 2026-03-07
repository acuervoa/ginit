#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

output="$("$SCRIPT_DIR/ginit.sh" --version)"

if [[ "$output" != "v1.0.1" ]]; then
  printf 'Expected version v1.0.1, got %s\n' "$output" >&2
  exit 1
fi

printf 'ok\n'

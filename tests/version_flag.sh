#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

output="$("$SCRIPT_DIR/ginit.sh" --version)"

if ! expected="$(git -C "$SCRIPT_DIR" describe --tags --abbrev=0 2>/dev/null)"; then
  expected="dev"
fi

if [[ "$output" != "$expected" ]]; then
  printf 'Expected version %s, got %s\n' "$expected" "$output" >&2
  exit 1
fi

printf 'ok\n'

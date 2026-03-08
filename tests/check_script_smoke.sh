#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -x "$SCRIPT_DIR/scripts/check.sh" ]]; then
  printf 'Expected scripts/check.sh to exist and be executable\n' >&2
  exit 1
fi

printf 'ok\n'

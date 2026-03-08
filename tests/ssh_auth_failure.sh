#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ssh() {
  printf 'Permission denied (publickey).\n' >&2
  return 255
}

# shellcheck disable=SC1091
source "$SCRIPT_DIR/ginit.sh"

REMOTE_MODE="ssh"

set +e
output="$(check_auth_for_remote_mode 2>&1)"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  printf 'Expected SSH auth check to fail\n' >&2
  exit 1
fi

if [[ "$output" != *"SSH authentication to GitHub failed"* ]]; then
  printf 'Expected SSH auth failure message, got: %s\n' "$output" >&2
  exit 1
fi

printf 'ok\n'

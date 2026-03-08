#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

curl() {
  printf '{"message":"Bad credentials"}\n401'
}

# shellcheck disable=SC1091
source "$SCRIPT_DIR/ginit.sh"

GITHUB_TOKEN="test-token"

set +e
output="$(validate_token 2>&1)"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  printf 'Expected invalid token validation to fail\n' >&2
  exit 1
fi

if [[ "$output" != *"invalid token or insufficient permissions"* ]]; then
  printf 'Expected token validation error, got: %s\n' "$output" >&2
  exit 1
fi

printf 'ok\n'

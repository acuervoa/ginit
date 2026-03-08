#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

curl() {
  printf '{"message":"Not Found"}\n404'
}

# shellcheck disable=SC1091
source "$SCRIPT_DIR/ginit.sh"

GITHUB_TOKEN="test-token"
GITHUB_OWNER="missing-owner"

set +e
output="$(resolve_owner_type 2>&1)"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  printf 'Expected missing owner lookup to fail\n' >&2
  exit 1
fi

if [[ "$output" != *"does not exist"* ]]; then
  printf 'Expected owner-not-found error, got: %s\n' "$output" >&2
  exit 1
fi

printf 'ok\n'

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/ginit.sh"

set +e
invalid_output="$(validate_repo_name "." 2>&1)"
invalid_status=$?
set -e

if [[ $invalid_status -eq 0 ]]; then
  printf 'Expected invalid repo name to fail\n' >&2
  exit 1
fi

if [[ "$invalid_output" != *"invalid repository name"* ]]; then
  printf 'Expected invalid name error, got: %s\n' "$invalid_output" >&2
  exit 1
fi

validate_repo_name "valid-repo.name_123"

printf 'ok\n'

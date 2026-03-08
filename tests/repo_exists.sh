#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

curl() {
  printf '{"full_name":"test-owner/existing-repo"}\n200'
}

# shellcheck disable=SC1091
source "$SCRIPT_DIR/ginit.sh"

GITHUB_TOKEN="test-token"
GITHUB_OWNER="test-owner"
REPO_NAME="existing-repo"

set +e
output="$(check_remote_repo_absent 2>&1)"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  printf 'Expected existing repo check to fail\n' >&2
  exit 1
fi

if [[ "$output" != *"already exists"* ]]; then
  printf 'Expected repository-exists error, got: %s\n' "$output" >&2
  exit 1
fi

printf 'ok\n'

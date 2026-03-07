#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export GITHUB_TOKEN="test-token"
export GITHUB_OWNER="test-owner"

curl() {
  case "$*" in
    *"https://api.github.com/user"*)
      printf '{"login":"test-user"}\n200'
      ;;
    *)
      printf '{}\n500'
      ;;
  esac
}

# shellcheck disable=SC1091
source "$SCRIPT_DIR/ginit.sh"

validate_token

if [[ "${API_STATUS:-}" != "200" ]]; then
  printf 'Expected API_STATUS=200, got %s\n' "${API_STATUS:-unset}" >&2
  exit 1
fi

printf 'ok\n'

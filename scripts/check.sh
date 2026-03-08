#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Error: required command not found: %s\n' "$1" >&2
    exit 1
  }
}

require_command bash
require_command shellcheck
require_command actionlint
require_command gitleaks

cd "$SCRIPT_DIR"

bash -n ginit.sh
bash -n install.sh

for test_script in tests/*.sh; do
  bash "$test_script"
done

shellcheck ginit.sh install.sh tests/*.sh
actionlint
gitleaks detect --no-git --source . --redact --exit-code 1

printf 'ok\n'

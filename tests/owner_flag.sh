#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
trap 'rm -f "$ENV_FILE"' EXIT

cat > "$ENV_FILE" <<'EOF'
GITHUB_TOKEN=test-token
GITHUB_OWNER=owner-from-env
EOF

export OWNER_OVERRIDE=""

# shellcheck disable=SC1091
source "$SCRIPT_DIR/ginit.sh"

OWNER_OVERRIDE="cli-owner"
load_env

if [[ "$GITHUB_OWNER" != "cli-owner" ]]; then
  printf 'Expected GITHUB_OWNER to be overridden, got %s\n' "$GITHUB_OWNER" >&2
  exit 1
fi

printf 'ok\n'

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
BIN_DIR="$WORK_DIR/bin"
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$BIN_DIR" "$WORK_DIR/project"

cat > "$BIN_DIR/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$1" in
  -C)
    shift 2
    exec git "$@"
    ;;
  rev-parse)
    if [[ "${2-}" == "--is-inside-work-tree" ]]; then
      exit 1
    fi
    if [[ "${2-}" == "--verify" ]]; then
      exit 1
    fi
    ;;
  remote)
    exit 0
    ;;
  describe)
    exit 1
    ;;
esac
exit 0
EOF

cat > "$BIN_DIR/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '{}\n200'
EOF

cat > "$BIN_DIR/ssh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'Hi test-user! You have successfully authenticated, but GitHub does not provide shell access.\n' >&2
exit 1
EOF

chmod +x "$BIN_DIR/git" "$BIN_DIR/curl" "$BIN_DIR/ssh"

cat > "$SCRIPT_DIR/.env" <<'EOF'
GITHUB_TOKEN=test-token
GITHUB_OWNER=test-owner
EOF

trap 'rm -rf "$WORK_DIR"; rm -f "$SCRIPT_DIR/.env"' EXIT

output="$(PATH="$BIN_DIR:$PATH" "$SCRIPT_DIR/ginit.sh" smoke-repo --dry-run --description "Test repository" --homepage "https://example.com/docs" 2>&1)"

if [[ "$output" != *"Dry run: would create remote repository 'test-owner/smoke-repo'"* ]]; then
  printf 'Expected dry-run remote creation message, got: %s\n' "$output" >&2
  exit 1
fi

if [[ "$output" != *'"description":"Test repository"'* ]]; then
  printf 'Expected description in dry-run payload, got: %s\n' "$output" >&2
  exit 1
fi

if [[ "$output" != *'"homepage":"https://example.com/docs"'* ]]; then
  printf 'Expected homepage in dry-run payload, got: %s\n' "$output" >&2
  exit 1
fi

if [[ "$output" != *"OK: dry run completed for 'test-owner/smoke-repo'."* ]]; then
  printf 'Expected dry-run success message, got: %s\n' "$output" >&2
  exit 1
fi

printf 'ok\n'

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

HOME="$WORK_DIR/home" PATH="/home/acuervo/.local/bin:$PATH" bash "$SCRIPT_DIR/install.sh"

if [[ ! -x "$WORK_DIR/home/.local/share/ginit/ginit.sh" ]]; then
  printf 'Expected installed ginit.sh in share directory\n' >&2
  exit 1
fi

if [[ ! -L "$WORK_DIR/home/.local/bin/ginit" ]]; then
  printf 'Expected ginit symlink in ~/.local/bin\n' >&2
  exit 1
fi

if [[ ! -f "$WORK_DIR/home/.local/share/ginit/.env" ]]; then
  printf 'Expected .env to be created from template\n' >&2
  exit 1
fi

printf 'ok\n'

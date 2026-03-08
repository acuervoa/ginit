#!/usr/bin/env bash
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

INSTALL_ROOT="${HOME}/.local/share/ginit"
BIN_DIR="${HOME}/.local/bin"
TARGET_BIN="${BIN_DIR}/ginit"

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Error: required command not found: %s\n' "$1" >&2
    exit 1
  }
}

copy_if_present() {
  local file_name="$1"

  if [[ -f "$SCRIPT_DIR/$file_name" ]]; then
    install -m 644 "$SCRIPT_DIR/$file_name" "$INSTALL_ROOT/$file_name"
  fi
}

detect_version() {
  local version

  if version="$(git -C "$SCRIPT_DIR" describe --tags --abbrev=0 2>/dev/null)"; then
    printf '%s\n' "$version"
    return
  fi

  printf 'dev\n'
}

require_command bash
require_command curl
require_command install
require_command ln

mkdir -p "$INSTALL_ROOT" "$BIN_DIR"

install -m 755 "$SCRIPT_DIR/ginit.sh" "$INSTALL_ROOT/ginit.sh"
printf '%s\n' "$(detect_version)" > "$INSTALL_ROOT/VERSION"
copy_if_present ".env.EXAMPLE"
copy_if_present "README.md"
copy_if_present "README_ES.md"
copy_if_present "CHANGELOG.md"
copy_if_present "CHANGELOG_ES.md"
copy_if_present "LICENSE"

if [[ ! -f "$INSTALL_ROOT/.env" && -f "$INSTALL_ROOT/.env.EXAMPLE" ]]; then
  cp "$INSTALL_ROOT/.env.EXAMPLE" "$INSTALL_ROOT/.env"
fi

ln -sf "$INSTALL_ROOT/ginit.sh" "$TARGET_BIN"

printf 'Installed ginit to %s\n' "$INSTALL_ROOT"
printf 'Linked command at %s\n' "$TARGET_BIN"

case ":${PATH}:" in
  *":${BIN_DIR}:"*) ;;
  *) printf 'Warning: %s is not currently in your PATH\n' "$BIN_DIR" >&2 ;;
esac

if [[ -f "$INSTALL_ROOT/.env" ]]; then
  printf 'Next step: edit %s with your GitHub token and owner.\n' "$INSTALL_ROOT/.env"
fi

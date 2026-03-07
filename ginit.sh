#!/usr/bin/env bash
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

DEFAULT_BRANCH="main"
VISIBILITY="private"
REMOTE_MODE="ssh"
DO_COMMIT=1
DRY_RUN=0
SHOW_VERSION=0
REPO_NAME=""

OWNER_TYPE=""
CREATED_REMOTE=0
API_STATUS=""
API_BODY=""

cleanup_on_error() {
  local exit_code=$?

  if [[ $exit_code -ne 0 && $CREATED_REMOTE -eq 1 ]]; then
    printf 'Warning: the remote repository was created but the script did not finish.\n' >&2
    printf 'You may need to review or delete %s/%s manually on GitHub.\n' "$GITHUB_OWNER" "$REPO_NAME" >&2
  fi

  exit "$exit_code"
}

trap cleanup_on_error EXIT

info() {
  printf '%s\n' "$*"
}

dry_run_note() {
  printf 'Dry run: %s\n' "$*"
}

warn() {
  printf 'Warning: %s\n' "$*" >&2
}

fatal() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  ginit.sh [repo-name] [--private|--public] [--remote ssh|https] [--no-commit] [--dry-run] [--version] [--help]

Options:
  repo-name         Repository name. Defaults to the current directory name.
  --private         Create a private repository (default).
  --public          Create a public repository.
  --remote MODE     Remote URL mode: ssh (default) or https.
  --no-commit       Skip the initial commit.
  --dry-run         Print planned actions without changing local or remote state.
  --version         Show the installed ginit version.
  --help, -h        Show this help message.
EOF
}

script_version() {
  local version

  if version="$(git -C "$SCRIPT_DIR" describe --tags --abbrev=0 2>/dev/null)"; then
    printf '%s\n' "$version"
    return
  fi

  printf 'dev\n'
}

require_command() {
  local command_name="$1"

  command -v "$command_name" >/dev/null 2>&1 || fatal "required command not found: $command_name"
}

load_env() {
  [[ -f "$ENV_FILE" ]] || fatal "file .env not found in $SCRIPT_DIR"

  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a

  : "${GITHUB_TOKEN:?Define GITHUB_TOKEN in .env}"
  : "${GITHUB_OWNER:?Define GITHUB_OWNER in .env}"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --private)
        VISIBILITY="private"
        ;;
      --public)
        VISIBILITY="public"
        ;;
      --remote)
        shift
        [[ $# -gt 0 ]] || fatal "--remote requires a value: ssh or https"
        case "$1" in
          ssh|https)
            REMOTE_MODE="$1"
            ;;
          *)
            fatal "invalid remote mode: $1"
            ;;
        esac
        ;;
      --no-commit)
        DO_COMMIT=0
        ;;
      --dry-run)
        DRY_RUN=1
        ;;
      --version)
        SHOW_VERSION=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      --*)
        fatal "unknown option: $1"
        ;;
      *)
        if [[ -n "$REPO_NAME" ]]; then
          fatal "repository name already provided: $REPO_NAME"
        fi
        REPO_NAME="$1"
        ;;
    esac
    shift
  done

  if [[ -z "$REPO_NAME" ]]; then
    REPO_NAME="$(basename "$PWD")"
  fi

  [[ -n "$REPO_NAME" ]] || fatal "could not determine repository name"
}

api_request() {
  local method="$1"
  local url="$2"
  local data="${3-}"
  local response

  if [[ -n "$data" ]]; then
    response="$(curl -sS -w $'\n%{http_code}' \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -X "$method" "$url" \
      -d "$data")"
  else
    response="$(curl -sS -w $'\n%{http_code}' \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -X "$method" "$url")"
  fi

  API_STATUS="${response##*$'\n'}"
  API_BODY="${response%$'\n'*}"
}

validate_token() {
  if [[ $DRY_RUN -eq 1 ]]; then
    dry_run_note "would validate GITHUB_TOKEN against GitHub"
    return
  fi

  api_request GET "https://api.github.com/user"
  if [[ "$API_STATUS" != "200" ]]; then
    fatal "invalid token or insufficient permissions (HTTP $API_STATUS). Response: $API_BODY"
  fi
}

resolve_owner_type() {
  local org_regex='"type"[[:space:]]*:[[:space:]]*"Organization"'
  local user_regex='"type"[[:space:]]*:[[:space:]]*"User"'

  if [[ $DRY_RUN -eq 1 ]]; then
    OWNER_TYPE="User"
    dry_run_note "would detect whether '$GITHUB_OWNER' is a GitHub user or organization"
    return
  fi

  api_request GET "https://api.github.com/users/$GITHUB_OWNER"
  case "$API_STATUS" in
    200)
      ;;
    404)
      fatal "GitHub owner '$GITHUB_OWNER' does not exist or is not visible with the current token"
      ;;
    *)
      fatal "could not inspect GitHub owner '$GITHUB_OWNER' (HTTP $API_STATUS). Response: $API_BODY"
      ;;
  esac

  if [[ "$API_BODY" =~ $org_regex ]]; then
    OWNER_TYPE="Organization"
  elif [[ "$API_BODY" =~ $user_regex ]]; then
    OWNER_TYPE="User"
  else
    fatal "could not determine whether '$GITHUB_OWNER' is a user or organization"
  fi
}

check_remote_repo_absent() {
  if [[ $DRY_RUN -eq 1 ]]; then
    dry_run_note "would verify that '$GITHUB_OWNER/$REPO_NAME' does not already exist"
    return
  fi

  api_request GET "https://api.github.com/repos/$GITHUB_OWNER/$REPO_NAME"
  case "$API_STATUS" in
    404)
      ;;
    200)
      fatal "repository '$REPO_NAME' already exists in $GITHUB_OWNER"
      ;;
    *)
      fatal "unexpected response while checking repository existence (HTTP $API_STATUS). Response: $API_BODY"
      ;;
  esac
}

ensure_git_repository() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ $DRY_RUN -eq 1 ]]; then
      dry_run_note "would initialize a local git repository"
    else
      info "Initializing local git repository"
      git init
    fi
  fi
}

ensure_no_origin_remote() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return
  fi

  if git remote | grep -qx 'origin'; then
    fatal "the local repository already has a remote named 'origin'"
  fi
}

check_auth_for_remote_mode() {
  if [[ "$REMOTE_MODE" == "ssh" ]]; then
    local ssh_output

    if [[ $DRY_RUN -eq 1 ]]; then
      dry_run_note "would verify SSH authentication with GitHub"
      return
    fi

    set +e
    ssh_output="$(ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1)"
    set -e

    if [[ "$ssh_output" != *"successfully authenticated"* ]]; then
      fatal "SSH authentication to GitHub failed. Configure your SSH key first or use --remote https. Details: $ssh_output"
    fi
  fi
}

ensure_safe_staging_area() {
  local -a candidates=()
  local file

  shopt -s nullglob dotglob globstar

  for file in \
    .env \
    .env.* \
    *.pem \
    *.key \
    *.p12 \
    *.pfx \
    *.kdbx \
    id_rsa \
    id_rsa.pub \
    id_ed25519 \
    id_ed25519.pub \
    credentials.json \
    credentials-*.json \
    service-account*.json \
    .npmrc \
    .pypirc \
    .netrc; do
    [[ -e "$file" ]] || continue
    [[ "$file" == ".git"* ]] && continue

    if ! git check-ignore -q "$file"; then
      candidates+=("$file")
    fi
  done

  shopt -u nullglob dotglob globstar

  if [[ ! -f .gitignore ]]; then
    warn "no .gitignore found in $(pwd); review staged files carefully"
  fi

  if [[ ${#candidates[@]} -gt 0 ]]; then
    printf 'Error: possible sensitive files detected and not ignored:\n' >&2
    printf '  - %s\n' "${candidates[@]}" >&2
    printf 'Add them to .gitignore or remove them before running ginit.sh.\n' >&2
    exit 1
  fi
}

create_default_readme() {
  if [[ ! -f README.md ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      dry_run_note "would create README.md"
      return
    fi

    cat > README.md <<EOF
# $REPO_NAME

Repository created automatically with ginit.sh.
EOF
  fi
}

create_remote_repository() {
  local url
  local payload

  if [[ "$OWNER_TYPE" == "Organization" ]]; then
    url="https://api.github.com/orgs/$GITHUB_OWNER/repos"
  else
    url="https://api.github.com/user/repos"
  fi

  payload="$(printf '{"name":"%s","private":%s,"visibility":"%s","auto_init":false}' \
    "$REPO_NAME" \
    "$([[ "$VISIBILITY" == "private" ]] && printf 'true' || printf 'false')" \
    "$VISIBILITY")"

  if [[ $DRY_RUN -eq 1 ]]; then
    dry_run_note "would create remote repository '$GITHUB_OWNER/$REPO_NAME' via $url"
    dry_run_note "payload: $payload"
    return
  fi

  api_request POST "$url" "$payload"
  if [[ "$API_STATUS" != "201" ]]; then
    fatal "failed to create repository '$REPO_NAME' in $GITHUB_OWNER (HTTP $API_STATUS). Response: $API_BODY"
  fi

  CREATED_REMOTE=1
  info "Remote repository '$GITHUB_OWNER/$REPO_NAME' created as $VISIBILITY"
}

stage_and_commit() {
  if [[ $DRY_RUN -eq 1 ]]; then
    dry_run_note "would stage all files with git add --all"

    if [[ $DO_COMMIT -eq 0 ]]; then
      dry_run_note "would skip the initial commit because --no-commit was requested"
    else
      dry_run_note "would create commit 'Initial commit' if there are staged changes"
    fi
    return
  fi

  git add --all

  if [[ $DO_COMMIT -eq 0 ]]; then
    info "Skipping initial commit because --no-commit was requested"
    return
  fi

  if git diff --cached --quiet; then
    info "No changes to commit"
    return
  fi

  git commit -m "Initial commit"
}

remote_url() {
  if [[ "$REMOTE_MODE" == "ssh" ]]; then
    printf 'git@github.com:%s/%s.git' "$GITHUB_OWNER" "$REPO_NAME"
  else
    printf 'https://github.com/%s/%s.git' "$GITHUB_OWNER" "$REPO_NAME"
  fi
}

configure_remote_and_branch() {
  if [[ $DRY_RUN -eq 1 ]]; then
    dry_run_note "would add origin remote: $(remote_url)"
    dry_run_note "would rename the current branch to $DEFAULT_BRANCH"
    return
  fi

  git remote add origin "$(remote_url)"
  git branch -M "$DEFAULT_BRANCH"
}

push_initial_branch() {
  if [[ $DRY_RUN -eq 1 ]]; then
    if [[ $DO_COMMIT -eq 0 ]]; then
      dry_run_note "would skip push because --no-commit was requested"
    else
      dry_run_note "would push '$DEFAULT_BRANCH' and set upstream to origin/$DEFAULT_BRANCH"
    fi
    return
  fi

  if [[ $DO_COMMIT -eq 0 ]]; then
    info "Remote configured, but no commit was created. Push skipped."
    return
  fi

  if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    info "Remote configured, but there is no local commit to push."
    return
  fi

  git push -u origin "$DEFAULT_BRANCH"
}

main() {
  parse_args "$@"

  if [[ $SHOW_VERSION -eq 1 ]]; then
    script_version
    return
  fi

  require_command git
  require_command curl
  load_env
  validate_token
  resolve_owner_type
  check_auth_for_remote_mode
  check_remote_repo_absent
  ensure_git_repository
  ensure_no_origin_remote
  ensure_safe_staging_area
  create_default_readme
  stage_and_commit
  create_remote_repository
  configure_remote_and_branch
  push_initial_branch

  if [[ $DRY_RUN -eq 1 ]]; then
    info "OK: dry run completed for '$GITHUB_OWNER/$REPO_NAME'."
    return
  fi

  info "OK: local repository linked and published as '$GITHUB_OWNER/$REPO_NAME'."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

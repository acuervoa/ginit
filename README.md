# ginit.sh

`ginit.sh` creates a GitHub repository from the current directory, initializes Git when needed, adds a first commit, configures `origin`, and pushes `main`.

## Features

- Works from any directory and resolves its own `.env` file.
- Supports GitHub users and organizations.
- Creates private repositories by default.
- Supports `ssh` or `https` remotes.
- Blocks common sensitive files before staging.
- Can skip the first commit with `--no-commit`.
- Includes a `--dry-run` mode for safe validation.

## Requirements

- `git`
- `curl`
- A GitHub personal access token with repository creation permissions.
- SSH configured for GitHub if you use the default `ssh` remote mode.

## Configuration

Create `.env` next to `ginit.sh` using `.env.EXAMPLE` as a template:

```env
GITHUB_TOKEN=your_token_here
GITHUB_OWNER=your_github_user_or_org
```

## Usage

```bash
./ginit.sh [repo-name] [--private|--public] [--remote ssh|https] [--no-commit] [--dry-run]
```

Examples:

```bash
./ginit.sh
./ginit.sh my-new-repo
./ginit.sh my-public-repo --public
./ginit.sh my-repo --remote https
./ginit.sh my-repo --no-commit
./ginit.sh my-repo --dry-run
```

If `repo-name` is omitted, the script uses the current directory name.

## Safety checks

Before publishing, the script:

- validates the GitHub token
- detects whether `GITHUB_OWNER` is a user or organization
- checks that the target repository does not already exist
- refuses to continue if `origin` already exists locally
- verifies SSH authentication when `--remote ssh` is used
- aborts if likely sensitive files are present and not ignored

## Notes

- `--private` is the default mode.
- With `--no-commit`, the remote is created and `origin` is configured, but nothing is pushed.
- With `--dry-run`, the script prints the actions it would take and skips local and remote mutations.
- The script warns if the remote repository was created but a later step failed.

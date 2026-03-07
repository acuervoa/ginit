# ginit

[![CI](https://github.com/acuervoa/ginit/actions/workflows/ci.yml/badge.svg)](https://github.com/acuervoa/ginit/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/acuervoa/ginit)](https://github.com/acuervoa/ginit/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Spanish version: [`README_ES.md`](README_ES.md)

Latest release notes: [`CHANGELOG.md`](CHANGELOG.md)

Spanish changelog: [`CHANGELOG_ES.md`](CHANGELOG_ES.md)

`ginit` creates a GitHub repository from the current directory, initializes Git when needed, creates an initial commit, configures `origin`, and publishes `main`.

## Features

- Works from any directory and resolves its own `.env` file.
- Supports both GitHub users and organizations.
- Creates private repositories by default.
- Supports `ssh` and `https` remotes.
- Blocks common sensitive files before staging.
- Can skip the initial commit with `--no-commit`.
- Includes a `--dry-run` mode for safe validation.
- Shows the installed version with `--version`.

## Installation

Place the repository in a stable path, for example:

```bash
mkdir -p ~/.local/share
git clone https://github.com/acuervoa/ginit.git ~/.local/share/ginit
chmod +x ~/.local/share/ginit/ginit.sh
ln -sf ~/.local/share/ginit/ginit.sh ~/.local/bin/ginit
```

Make sure `~/.local/bin` is in your `PATH`.

## Requirements

- `git`
- `curl`
- `bash`
- `ssh` if you use the default `ssh` remote mode

## Configuration

`ginit` loads the `.env` file stored next to the installed script, not the one from the project where you run it.

If you installed the command as shown above, create this file:

```env
# ~/.local/share/ginit/.env
GITHUB_TOKEN=your_token_here
GITHUB_OWNER=your_github_user_or_org
```

You can also copy `.env.EXAMPLE` and fill it in.

### Token permissions

- Classic PAT: `repo`
- Fine-grained token: permissions to create repositories in the selected owner
- If `GITHUB_OWNER` is an organization, the token must be allowed to create repositories in that organization

## Usage

```bash
ginit [repo-name] [--private|--public] [--remote ssh|https] [--no-commit] [--dry-run] [--version]
```

Examples:

```bash
ginit
ginit my-new-repo
ginit my-public-repo --public
ginit my-repo --remote https
ginit my-repo --no-commit
ginit my-repo --dry-run
ginit --version
ginit --help
```

If `repo-name` is omitted, the script uses the current directory name.

Do not use `ginit .`: `.` is not a valid GitHub repository name.

## Safety checks

Before publishing, the script:

- validates the GitHub token
- detects whether `GITHUB_OWNER` is a user or an organization
- checks that the target repository does not already exist
- refuses to continue if `origin` already exists locally
- verifies SSH authentication when `--remote ssh` is used
- aborts if it finds likely sensitive files that are not ignored

## Troubleshooting

- `Bad credentials`
  - check `GITHUB_TOKEN` in the `.env` file located in the `ginit` installation directory
- `invalid remote mode`
  - use only `ssh` or `https`
- invalid repository name or `ginit .`
  - run `ginit` or `ginit your-repo-name`, not `ginit .`
- SSH failure
  - try `ginit --remote https` or configure your SSH key in GitHub

## Development

Local checks:

```bash
bash -n ginit.sh
bash tests/version_flag.sh
bash tests/api_status_regression.sh
shellcheck ginit.sh tests/*.sh
```

The repository includes GitHub Actions CI to run these checks on every push and pull request.

Release notes are written in English by default. Use `.github/RELEASE_TEMPLATE.md` as the starting point for future releases.

## License

MIT. See `LICENSE`.

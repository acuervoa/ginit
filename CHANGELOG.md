# Changelog

Spanish version: [`CHANGELOG_ES.md`](CHANGELOG_ES.md)

Release notes default to English. For future releases, start from [`.github/RELEASE_TEMPLATE.md`](.github/RELEASE_TEMPLATE.md).

## v1.1.0

- prepare the project for public release with an MIT license, GitHub Actions CI, and fuller documentation
- add README badges and clarify installation, token permissions, and troubleshooting
- update the tests so `--version` follows the latest real tag in the repository

## v1.0.3

- improve `ginit --help` so it shows the actual invoked command name
- add a short description at the top of the help output

## v1.0.2

- add `--version` to show the latest available tag
- introduce `CHANGELOG.md`
- document the new flag and cover it with an automated test

## v1.0.1

- fix the loss of `API_STATUS` when returning from subshells
- add a regression test for the authentication flow

## v1.0.0

- harden `ginit.sh` with stricter validation and clearer error handling
- add `--dry-run` to preview changes without modifying local or remote state
- update the documentation and `.env.EXAMPLE`

## v1.0.0-rc.1

- publish the initial hardened refactor release candidate

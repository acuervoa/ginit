# Changelog

Spanish version: [`CHANGELOG_ES.md`](CHANGELOG_ES.md)

Release notes default to English. For future releases, start from [`.github/RELEASE_TEMPLATE.md`](.github/RELEASE_TEMPLATE.md).

## Unreleased

### Added
- support for `--description` during repository creation
- support for `--homepage` during repository creation
- homepage validation and dry-run payload regressions
- a single `scripts/check.sh` command for local quality checks
- API and SSH error-path regression tests for token, owner, repository, and auth failures

### Changed
- `Unreleased` now tracks only post-`v1.3.1` work

## v1.1.3

- add an English-first `CHANGELOG.md` and a Spanish `CHANGELOG_ES.md`
- make CI fetch tags and harden the version regression test for tagless environments
- add `.github/RELEASE_TEMPLATE.md` so future release notes start in English by default

## v1.1.2

- make English the default GitHub README
- move the Spanish guide to `README_ES.md`
- keep cross-links between both documentation versions

## v1.1.1

- add `README_EN.md` with a full English guide
- cross-link the Spanish and English documentation
- link the English guide to the changelog

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

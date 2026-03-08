# Changelog

Spanish version: [`CHANGELOG_ES.md`](CHANGELOG_ES.md)

Release notes default to English. For future releases, start from [`.github/RELEASE_TEMPLATE.md`](.github/RELEASE_TEMPLATE.md).

## Unreleased

## v1.5.1

- backfill `CHANGELOG.md` and `CHANGELOG_ES.md` so the published changelog matches releases from `v1.2.0` through `v1.5.0`
- reset `Unreleased` to an empty state after the published releases

## v1.5.0

- add `scripts/check.sh` as the single local quality command
- make GitHub Actions run the same local check suite
- add regression tests for invalid token, missing owner, existing repository, and SSH authentication failures

## v1.4.0

- add `--description` and `--homepage` for repository creation metadata
- validate homepage URLs locally and cover them with regression tests
- clean up `Unreleased` to track only post-`v1.3.1` work

## v1.3.1

- preserve installed version metadata with a local `VERSION` file
- make `ginit --version` prefer installed version metadata before Git tags or `dev`
- add a regression test for installed version reporting

## v1.3.0

- add `install.sh` to install `ginit` into `~/.local/share/ginit` and link `~/.local/bin/ginit`
- add `--owner` to override `GITHUB_OWNER` for a single invocation
- add installer and owner-override regression coverage, including the CI fix for `actionlint` installation

## v1.2.0

- validate repository names locally before calling the GitHub API
- add repo-name validation and `--dry-run` smoke regressions
- harden CI with `actionlint`, `gitleaks`, and release workflow improvements

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

# AI Coding Guidelines

## Commands

- **Test:** `bats test/bats/`
- **Lint/format (all checks):** `pre-commit run --all-files`
- **Format a single shell file:** `shfmt --indent 2 -w <file>`
- **Run a single test file:** `bats test/bats/<file>.bats`

Run `pre-commit run --all-files && bats test/bats/` before marking any change complete.

## Setup

New contributors must run `pre-commit install` before their first commit — otherwise shellcheck, shfmt, and markdownlint hooks won't run locally.

## Shell Code Rules

- Target: bash 4+ and zsh 5+. This is **not** POSIX sh.
- Use `[ ]` (POSIX test) in code that runs before the shell is detected; use `[[ ]]` after shell detection.
- `shellcheck disable` comments are **intentional** — do not remove them. They mark places where POSIX compliance is deliberately violated (e.g., SC2292 before shell detection, SC2139 for alias expansion at source time).
- 2-space indentation, LF line endings (enforced by shfmt and .editorconfig).

## Git Workflow

- Branch naming: `type/short-description` (e.g. `fix/shellcheck-warnings`, `feat/debug-mode`, `chore/update-deps`)
- Commit messages: [Conventional Commits](https://www.conventionalcommits.org/) (e.g. `fix: address shellcheck warnings`, `feat: add debug mode`)
- Never push directly to `main` — always open a PR.
- Release tags matching `v*.*.*` trigger the release workflow, which updates the Homebrew tap via PR (requires `HOMEBREW_TAP_TOKEN` secret).

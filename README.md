# set-tf-alias

Portable bash/zsh shell library that auto-switches `tf`, `tofu`, and
`terraform` aliases based on `.opentofu-version` / `.terraform-version` files
and [`tenv`](https://tofuutils.github.io/tenv/) integration. Works on macOS
and Linux under bash ≥ 4 and zsh ≥ 5.

## What it does

When you `cd` into a project, `set-tf-alias` walks up the directory tree
looking for `.opentofu-version` or `.terraform-version`. If it finds one, it
invokes `tenv` to install and activate the pinned version, and points `tf`,
`tofu`, and `terraform` at the right binary. When no version file is present,
it falls back to reading `.terraform.lock.hcl` for the provider registry,
then to the presence of `*.tofu` files in the current directory.

## Demo

```text
$ cd my-opentofu-project
✓ set_tf_alias: tofu 1.8.5 (via .opentofu-version)
$ tf plan          # runs opentofu 1.8.5

$ cd ../legacy-terraform-project
✓ set_tf_alias: terraform 1.5.7 (via .terraform-version)
$ tf plan          # runs terraform 1.5.7
```

## Install

### Homebrew (recommended)

```bash
brew tap langburd/tap
brew install set-tf-alias
```

Then add this line to your `~/.zshrc` or `~/.bashrc`:

```bash
source "$(brew --prefix)/share/set-tf-alias/set-tf-alias.sh"
```

Bash users: ensure bash ≥ 4 with `brew install bash`. Apple's default bash 3.2
is not supported.

### `curl | sh`

```bash
curl -fsSL https://raw.githubusercontent.com/langburd/set-tf-alias/v0.1.0/install.sh | sh
```

The installer downloads the library at a pinned tag, installs it to
`~/.local/share/set-tf-alias/set-tf-alias.sh`, and appends a source line to
your rc. It's idempotent — re-run it to upgrade.

### Manual

```bash
git clone https://github.com/langburd/set-tf-alias.git ~/.local/share/set-tf-alias
echo 'source ~/.local/share/set-tf-alias/set-tf-alias.sh' >> ~/.zshrc
```

## Configuration

| Variable | Default | Effect |
| --- | --- | --- |
| `SET_TF_ALIAS_AUTOHOOK` | `1` | Set to `0` to disable the `chpwd` / `PROMPT_COMMAND` hook AND the initial invocation. `set_tf_alias` remains defined so you can call it manually. |
| `SET_TF_ALIAS_DEBUG` | `0` | Set to `1` to print detection steps to stderr. |

## How detection works

1. Walk up from `$PWD`. First `.opentofu-version` or `.terraform-version`
   file wins.
2. If no version file, check `.terraform.lock.hcl` in `$PWD`:
   `registry.opentofu.org` → `tofu`.
3. If no lockfile match, check for `*.tofu` files in `$PWD` → `tofu`.
4. Otherwise, alias to the system `terraform` binary.

## Requirements

- bash ≥ 4 **or** zsh ≥ 5.
- [`tenv`](https://tofuutils.github.io/tenv/) recommended (the library works
  without it, but won't install pinned versions automatically).

## Troubleshooting

```bash
SET_TF_ALIAS_DEBUG=1 set_tf_alias
```

Paste the output in a GitHub issue.

## Contributing

```bash
git clone https://github.com/langburd/set-tf-alias.git
cd set-tf-alias
pre-commit install
bats test/bats/
```

Open a PR against `main`. Bug reports and feature requests are welcome via
GitHub Issues.

Maintainer note: for releases, a `HOMEBREW_TAP_TOKEN` secret (PAT with `repo`
scope on `langburd/homebrew-tap`) must be configured in the repo's Actions
secrets so the release workflow can open bump PRs.

## License

MIT. See [LICENSE](LICENSE).

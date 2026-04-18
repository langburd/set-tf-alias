#!/usr/bin/env bash
# set-tf-alias — portable bash/zsh library that auto-switches tf/tofu/terraform
# aliases based on .opentofu-version / .terraform-version files.
#
# Source this file from ~/.bashrc or ~/.zshrc:
#   source "/path/to/set-tf-alias.sh"
#
# Configuration (environment variables):
#   SET_TF_ALIAS_AUTOHOOK  1 (default) wires chpwd/PROMPT_COMMAND; 0 disables
#                          hook AND initial invocation. The function remains
#                          defined for manual calls.
#   SET_TF_ALIAS_DEBUG     1 prints detection steps to stderr. Default 0.

# ---------------------------------------------------------------------------
# Shell detection
# ---------------------------------------------------------------------------
if [ -n "${ZSH_VERSION-}" ]; then
  __STF_SHELL=zsh
elif [ -n "${BASH_VERSION-}" ]; then
  __STF_SHELL=bash
else
  printf 'set-tf-alias.sh: requires bash >= 4 or zsh; refusing to load under %s\n' "$0" >&2
  # shellcheck disable=SC2317
  return 0 2>/dev/null || exit 0
fi

# ---------------------------------------------------------------------------
# Bash version guard (bash >= 4 required)
# ---------------------------------------------------------------------------
if [ "$__STF_SHELL" = bash ] && [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  printf '\033[31mset-tf-alias: requires bash >= 4 (detected %s). Install via: brew install bash\033[0m\n' \
    "$BASH_VERSION" >&2
  unset __STF_SHELL
  return 0
fi

# ---------------------------------------------------------------------------
# Detection helpers (private, prefixed __stf_)
# ---------------------------------------------------------------------------

# Walks up from $PWD to /. Echoes "tofu:<path>" or "tf:<path>" on success.
# Returns 0 if found, 1 if no version file was found in any ancestor.
__stf_find_version_file() {
  local dir=$PWD
  while :; do
    if [ -f "$dir/.opentofu-version" ]; then
      printf 'tofu:%s/.opentofu-version\n' "$dir"
      return 0
    fi
    if [ -f "$dir/.terraform-version" ]; then
      printf 'tf:%s/.terraform-version\n' "$dir"
      return 0
    fi
    [ "$dir" = "/" ] && return 1
    dir=${dir%/*}
    [ -z "$dir" ] && dir=/
  done
}

# Returns 0 if .terraform.lock.hcl in $PWD references registry.opentofu.org.
__stf_check_lockfile() {
  [ -f .terraform.lock.hcl ] && grep -q 'registry\.opentofu\.org' .terraform.lock.hcl
}

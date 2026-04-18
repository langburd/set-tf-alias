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

# Runs `tenv <kind> detect -i -q`. Echoes the resolved version on stdout.
# On failure, surfaces tenv's stderr and returns non-zero.
__stf_run_tenv_detect() {
  local kind=$1 output rc
  output=$(tenv "$kind" detect -i -q 2>&1)
  rc=$?
  if [ $rc -ne 0 ]; then
    printf '%s\n' "$output" >&2
    return $rc
  fi
  # Output format: "OpenTofu 1.8.5 will be run from this directory."
  # Extract the second whitespace-separated field portably across bash/zsh.
  printf '%s\n' "$output" | awk '{print $2}'
}

# Prints "$2" in the given color, or plain text if output isn't a TTY.
# $1 = color name (red|green|yellow|cyan), $2 = message.
__stf_color() {
  local code
  case "$1" in
  red) code='31' ;;
  green) code='32' ;;
  yellow) code='33' ;;
  cyan) code='36' ;;
  *) code='0' ;;
  esac
  if [ -t 1 ] || [ -t 2 ]; then
    printf '\033[%sm%s\033[0m\n' "$code" "$2"
  else
    printf '%s\n' "$2"
  fi
}

# Prints a yellow one-shot warning to stderr when tenv is missing but a
# version file was found. Subsequent calls in the same shell are silent.
__stf_warn_tenv_missing() {
  [ "${_SET_TF_ALIAS_TENV_WARNED:-0}" = 1 ] && return 0
  __stf_color yellow \
    '⚠ set_tf_alias: tenv not installed — aliasing to system tofu/terraform. Install: https://tofuutils.github.io/tenv/' \
    >&2
  _SET_TF_ALIAS_TENV_WARNED=1
}

# Sets the full tf*/tofu/terraform alias set to the named binary.
# If $1 is empty, unsets all aliases (so $PATH decides).
# shellcheck disable=SC2139
__stf_set_aliases() {
  local bin=$1
  if [ -z "$bin" ]; then
    unalias tf tfa tfaa tfat tfc tfd tfdt tff tffr tfg tfi tfim tfir tfiu \
      tfo tfp tfpsum tfpt tfs tfsh tft tfv tfw tfws tofu terraform 2>/dev/null || true
    return 0
  fi
  alias tf="$bin"
  alias tfa="$bin apply"
  alias tfaa="$bin apply -auto-approve"
  alias tfat="$bin apply -target"
  alias tfc="$bin console"
  alias tfd="$bin destroy"
  alias tfdt="$bin destroy -target"
  alias tff="$bin fmt"
  alias tffr="$bin fmt -recursive"
  alias tfg="$bin get"
  alias tfi="$bin init"
  alias tfim="$bin init -migrate-state"
  alias tfir="$bin init -reconfigure"
  alias tfiu="$bin init -upgrade"
  alias tfo="$bin output"
  alias tfp="$bin plan"
  alias tfpsum="$bin plan | grep -E '(will|must) be'"
  alias tfpt="$bin plan -target"
  alias tfs="$bin state"
  alias tfsh="$bin show"
  alias tft="$bin test"
  alias tfv="$bin validate"
  alias tfw="$bin workspace"
  alias tfws="$bin workspace select"
  alias tofu="$bin"
  alias terraform="$bin"
  alias tfa="$bin apply"
  alias tfaa="$bin apply -auto-approve"
  alias tfat="$bin apply -target"
  alias tfc="$bin console"
  alias tfd="$bin destroy"
  alias tfdt="$bin destroy -target"
  alias tff="$bin fmt"
  alias tffr="$bin fmt -recursive"
  alias tfg="$bin get"
  alias tfi="$bin init"
  alias tfim="$bin init -migrate-state"
  alias tfir="$bin init -reconfigure"
  alias tfiu="$bin init -upgrade"
  alias tfo="$bin output"
  alias tfp="$bin plan"
  alias tfpsum="$bin plan | grep -E '(will|must) be'"
  alias tfpt="$bin plan -target"
  alias tfs="$bin state"
  alias tfsh="$bin show"
  alias tft="$bin test"
  alias tfv="$bin validate"
  alias tfw="$bin workspace"
  alias tfws="$bin workspace select"
  alias tofu="$bin"
  alias terraform="$bin"
}

# Returns 0 if at least one *.tofu file exists in $PWD.
# Handles both shells' no-match behavior: bash leaves the glob literal (caught
# by `[ -e ]`), zsh would error by default so we scope `nullglob` to the fn.
__stf_has_tofu_files() {
  if [ -n "${ZSH_VERSION-}" ]; then
    setopt localoptions nullglob
  fi
  local f
  for f in ./*.tofu; do
    [ -e "$f" ] && return 0
  done
  return 1
}

# ---------------------------------------------------------------------------
# Public orchestrator
# ---------------------------------------------------------------------------
set_tf_alias() {
  local detect_result kind version_file_path binary version
  local display_path

  detect_result=$(__stf_find_version_file || true)

  if [ -n "$detect_result" ]; then
    kind=${detect_result%%:*}
    version_file_path=${detect_result#*:}
    display_path=${version_file_path##*/}
    [ "$kind" = "tofu" ] && binary=tofu || binary=terraform

    if command -v tenv >/dev/null 2>&1; then
      if version=$(__stf_run_tenv_detect "$kind"); then
        __stf_set_aliases "$binary"
        __stf_color green \
          "✓ set_tf_alias: $binary $version (via $display_path)"
        return 0
      else
        __stf_color red \
          "✗ set_tf_alias: tenv failed to install $binary — aliasing to system $binary" >&2
        __stf_set_aliases "$binary"
        return 0
      fi
    else
      __stf_warn_tenv_missing
      __stf_set_aliases "$binary"
      return 0
    fi
  fi

  # No version file — try lockfile
  if __stf_check_lockfile; then
    __stf_set_aliases tofu
    return 0
  fi

  # No version file, no lockfile — try *.tofu glob
  if __stf_has_tofu_files; then
    __stf_set_aliases tofu
    return 0
  fi

  # Nothing found — unset aliases
  __stf_set_aliases ''
}

# ---------------------------------------------------------------------------
# Hook wiring (gated by SET_TF_ALIAS_AUTOHOOK, default 1)
# ---------------------------------------------------------------------------
: "${SET_TF_ALIAS_AUTOHOOK:=1}"

__stf_is_interactive() {
  case "$-" in
  *i*) return 0 ;;
  *) return 1 ;;
  esac
}

if [ "$SET_TF_ALIAS_AUTOHOOK" = 1 ]; then
  if [ "$__STF_SHELL" = zsh ]; then
    # shellcheck disable=SC1090,SC2296
    autoload -Uz add-zsh-hook 2>/dev/null || true
    add-zsh-hook chpwd set_tf_alias 2>/dev/null || true
  elif [ "$__STF_SHELL" = bash ]; then
    __stf_prompt_hook() {
      if [ "$PWD" != "${__STF_LAST_PWD-}" ]; then
        __STF_LAST_PWD=$PWD
        set_tf_alias
      fi
    }
    # Append to PROMPT_COMMAND, idempotently.
    case "${PROMPT_COMMAND-}" in
    *__stf_prompt_hook*) : ;;
    '') PROMPT_COMMAND='__stf_prompt_hook' ;;
    *) PROMPT_COMMAND="__stf_prompt_hook; ${PROMPT_COMMAND}" ;;
    esac
  fi
fi

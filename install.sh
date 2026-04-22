#!/usr/bin/env bash
# set-tf-alias installer.
# Downloads set-tf-alias.sh at a pinned tag, installs it to the XDG data dir,
# and appends a source line to the user's rc.

set -eu

STF_REPO="${STF_REPO:-langburd/set-tf-alias}"
STF_TAG="${STF_TAG:-v0.1.0}"
STF_URL="https://raw.githubusercontent.com/${STF_REPO}/${STF_TAG}/set-tf-alias.sh"

red() { printf '\033[31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*" >&2; }

detect_shell() {
  case "${SHELL:-}" in
  */zsh) echo zsh ;;
  */bash) echo bash ;;
  *)
    red "set-tf-alias: supports bash >= 4 and zsh only (detected SHELL=${SHELL})"
    exit 1
    ;;
  esac
}

check_bash_version() {
  local v
  # shellcheck disable=SC2016  # single quotes are intentional: let $SHELL expand $BASH_VERSINFO
  v=$("${SHELL}" -c 'echo $BASH_VERSINFO' 2>/dev/null || echo 0)
  if [[ "${v}" -lt 4 ]]; then
    red "set-tf-alias: requires bash >= 4 (detected ${v}). Install via: brew install bash"
    exit 1
  fi
}

rc_file_for() {
  case "${1}" in
  zsh) echo "${HOME}/.zshrc" ;;
  bash) echo "${HOME}/.bashrc" ;;
  *) red "set-tf-alias: unsupported shell: ${1}"; exit 1 ;;
  esac
}

main() {
  local shell rc install_dir install_path source_line
  shell=$(set -e; detect_shell)
  [[ "${shell}" = bash ]] && check_bash_version

  install_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/set-tf-alias"
  install_path="${install_dir}/set-tf-alias.sh"
  rc=$(set -e; rc_file_for "${shell}")

  mkdir -p "${install_dir}"
  if ! curl -fsSL "${STF_URL}" -o "${install_path}"; then
    red "set-tf-alias: failed to download ${STF_URL}"
    exit 1
  fi
  chmod 0644 "${install_path}"

  source_line="source \"${install_path}\""

  if [[ ! -f "${rc}" ]]; then
    : >"${rc}"
  fi

  if grep -Fq "set-tf-alias.sh" "${rc}"; then
    yellow "set-tf-alias: source line already present in ${rc} (skipped)"
  else
    printf '\n# set-tf-alias (auto-installed)\n%s\n' "${source_line}" >>"${rc}"
    green "set-tf-alias: appended source line to ${rc}"
  fi

  green "✓ installed to ${install_path}; restart your shell or run: source ${rc}"
}

main "$@"

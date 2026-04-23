#!/usr/bin/env bash
# set-tf-alias installer.
# Downloads set-tf-alias.sh at the latest release tag (or $STF_TAG if set),
# installs it to the XDG data dir, and appends a source line to the user's rc.

set -eu
shopt -s inherit_errexit 2>/dev/null || true # bash 4.4+; silently skipped, version checked below

red() { printf '\033[31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*" >&2; }

STF_REPO="${STF_REPO:-langburd/set-tf-alias}"
if [[ -n "${STF_TAG:-}" ]]; then
  STF_URL="https://raw.githubusercontent.com/${STF_REPO}/${STF_TAG}/set-tf-alias.sh"
else
  STF_URL="https://github.com/${STF_REPO}/releases/latest/download/set-tf-alias.sh"
fi

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
  *)
    red "set-tf-alias: unsupported shell: ${1}"
    exit 1
    ;;
  esac
}

main() {
  local shell rc install_dir install_path source_line
  shell=$(detect_shell)
  [[ "${shell}" = bash ]] && check_bash_version

  install_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/set-tf-alias"
  install_path="${install_dir}/set-tf-alias.sh"
  rc=$(rc_file_for "${shell}")

  mkdir -p "${install_dir}"
  local effective_url
  if ! effective_url=$(curl -fsSL "${STF_URL}" -o "${install_path}" --write-out '%{url_effective}'); then
    red "set-tf-alias: failed to download ${STF_URL}"
    exit 1
  fi
  chmod 0644 "${install_path}"
  # Extract tag from effective URL when not explicitly pinned via $STF_TAG
  if [[ -z "${STF_TAG:-}" ]]; then
    STF_TAG=$(printf '%s' "${effective_url}" | sed 's|.*/releases/download/\([^/]*\)/.*|\1|')
    [[ "${STF_TAG}" =~ ^v[0-9] ]] || STF_TAG=""
  fi
  [[ -n "${STF_TAG:-}" ]] && printf '%s\n' "${STF_TAG#v}" >"${install_dir}/version.txt"

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

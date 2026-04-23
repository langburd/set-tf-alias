#!/usr/bin/env bats

load ../helpers

setup() {
  _tmpbase="${TMPDIR:-/tmp}"
  _tmpbase="${_tmpbase%/}"
  TEST_TMP="$(mktemp -d "${_tmpbase}/stf.XXXXXX")"
  export TEST_TMP
  export HOME="$TEST_TMP/home"
  mkdir -p "$HOME"
  # Stub curl so the installer doesn't hit the network.
  mkdir -p "$TEST_TMP/bin"
  cat >"$TEST_TMP/bin/curl" <<'EOF'
#!/usr/bin/env bash
# Minimal curl stub: handles releases/latest/download redirects and raw file requests.
output_file=""
write_out_format=""
prev=""
for arg in "$@"; do
  if [ "$prev" = "-o" ]; then output_file="$arg"; fi
  if [ "$prev" = "--write-out" ] || [ "$prev" = "-w" ]; then write_out_format="$arg"; fi
  prev="$arg"
done
for arg in "$@"; do
  case "$arg" in
    *releases/latest/download/set-tf-alias.sh*)
      effective_url="https://github.com/${STUB_STF_REPO:-langburd/set-tf-alias}/releases/download/v0.1.2/set-tf-alias.sh"
      if [ -n "$output_file" ]; then
        cat "${STF_INSTALLER_SOURCE:?}/set-tf-alias.sh" >"$output_file"
      else
        cat "${STF_INSTALLER_SOURCE:?}/set-tf-alias.sh"
      fi
      [ "$write_out_format" = '%{url_effective}' ] && printf '%s' "$effective_url"
      exit 0
      ;;
    *set-tf-alias.sh*)
      if [ -n "$output_file" ]; then
        cat "${STF_INSTALLER_SOURCE:?}/set-tf-alias.sh" >"$output_file"
      else
        cat "${STF_INSTALLER_SOURCE:?}/set-tf-alias.sh"
      fi
      [ "$write_out_format" = '%{url_effective}' ] && printf '%s' "$arg"
      exit 0
      ;;
  esac
done
exit 1
EOF
  chmod +x "$TEST_TMP/bin/curl"
  export PATH="$TEST_TMP/bin:$PATH"
  export STF_INSTALLER_SOURCE="${BATS_TEST_DIRNAME}/../.."
  cd "$TEST_TMP" || return 1
}

teardown() {
  cd / || true
  rm -rf "$TEST_TMP"
}

@test "installs to XDG data home and appends source line to ~/.zshrc" {
  # shellcheck disable=SC2030,SC2031  # bats runs each test in a subshell; SHELL export is intentional
  export SHELL=/bin/zsh
  touch "$HOME/.zshrc"
  run bash "${BATS_TEST_DIRNAME}/../../install.sh"
  [ "$status" -eq 0 ]
  [ -f "$HOME/.local/share/set-tf-alias/set-tf-alias.sh" ]
  grep -q 'source.*set-tf-alias.sh' "$HOME/.zshrc"
  [ -f "$HOME/.local/share/set-tf-alias/version.txt" ]
  [ "$(cat "$HOME/.local/share/set-tf-alias/version.txt")" = "0.1.2" ]
}

@test "is idempotent: re-run does not duplicate source line" {
  # shellcheck disable=SC2030,SC2031  # bats runs each test in a subshell; SHELL export is intentional
  export SHELL=/bin/zsh
  touch "$HOME/.zshrc"
  bash "${BATS_TEST_DIRNAME}/../../install.sh" >/dev/null
  bash "${BATS_TEST_DIRNAME}/../../install.sh" >/dev/null
  count=$(grep -c 'source.*set-tf-alias.sh' "$HOME/.zshrc")
  [ "$count" -eq 1 ]
}

@test "refuses unsupported shell" {
  # shellcheck disable=SC2031  # bats runs each test in a subshell; SHELL export is intentional
  export SHELL=/usr/bin/fish
  run bash "${BATS_TEST_DIRNAME}/../../install.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"supports bash >= 4 and zsh only"* ]]
}

@test "rc_file_for: unsupported shell exits non-zero with error message" {
  local tmpfile
  tmpfile=$(mktemp)
  # Strip the `main "$@"` call so we can invoke rc_file_for directly.
  grep -v '^main ' "${BATS_TEST_DIRNAME}/../../install.sh" >"$tmpfile"
  echo 'rc_file_for fish' >>"$tmpfile"
  run bash "$tmpfile"
  rm -f "$tmpfile"
  [ "$status" -ne 0 ]
  [[ "$output" == *"unsupported shell"* ]]
}

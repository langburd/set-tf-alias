#!/usr/bin/env bats

load ../helpers

setup() {
  _tmpbase="${TMPDIR:-/tmp}"
  _tmpbase="${_tmpbase%/}"
  TEST_TMP="$(mktemp -d "${_tmpbase}/stf.XXXXXX")"
  export TEST_TMP
  export PATH="${BATS_TEST_DIRNAME}/../bin:$PATH"
  echo "1.8.5" >"$TEST_TMP/.opentofu-version"
  cd "$TEST_TMP" || return 1
}

teardown() {
  cd / || true
  rm -rf "$TEST_TMP"
}

@test "SET_TF_ALIAS_DEBUG=1 prints detection steps to stderr" {
  run bash -c "
    shopt -s expand_aliases
    export SET_TF_ALIAS_DEBUG=1
    source '$STF_LIB' 2>&1
    SET_TF_ALIAS_AUTOHOOK=0 set_tf_alias 2>&1 >/dev/null
  "
  [[ "$output" == *"[debug]"* ]]
}

@test "debug off by default" {
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB' 2>&1
    SET_TF_ALIAS_AUTOHOOK=0 set_tf_alias 2>&1 >/dev/null
  "
  [[ "$output" != *"[debug]"* ]]
}

@test "piped output contains no ANSI escapes" {
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB'
    SET_TF_ALIAS_AUTOHOOK=0 set_tf_alias | cat
  "
  # ANSI escape starts with the ESC byte 0x1b
  printf '%s' "$output" | grep -q $'\033' && fail "found ANSI escape"
  [[ "$output" == *"set_tf_alias: tofu 1.8.5"* ]]
}

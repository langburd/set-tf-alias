#!/usr/bin/env bats

load ../helpers

setup() {
  _tmpbase="${TMPDIR:-/tmp}"
  _tmpbase="${_tmpbase%/}"
  TEST_TMP="$(mktemp -d "${_tmpbase}/stf.XXXXXX")"
  export TEST_TMP
  export PATH="${BATS_TEST_DIRNAME}/../bin:$PATH"
  cd "$TEST_TMP" || return 1
}

teardown() {
  cd / || true
  rm -rf "$TEST_TMP"
}

@test "zsh: chpwd hook fires set_tf_alias on cd" {
  mkdir -p "$TEST_TMP/project"
  echo "1.8.5" >"$TEST_TMP/project/.opentofu-version"
  run zsh -c "
    source '$STF_LIB'
    cd '$TEST_TMP/project'
    alias tf
  "
  [[ "$output" == *"tf=tofu"* ]]
  [[ "$output" == *"set_tf_alias: tofu 1.8.5"* ]]
}

@test "zsh: chpwd not wired when SET_TF_ALIAS_AUTOHOOK=0" {
  mkdir -p "$TEST_TMP/project"
  echo "1.8.5" >"$TEST_TMP/project/.opentofu-version"
  run zsh -c "
    export SET_TF_ALIAS_AUTOHOOK=0
    source '$STF_LIB'
    cd '$TEST_TMP/project'
    alias tf 2>&1 || echo 'unset'
  "
  [[ "$output" == *"unset"* ]]
}

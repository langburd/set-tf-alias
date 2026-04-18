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

@test "bash: initial invocation sets aliases on source" {
  run bash -ic "
    shopt -s expand_aliases
    cd '$TEST_TMP'
    source '$STF_LIB'
    alias tf
  "
  [[ "$output" == *"alias tf='tofu'"* ]]
}

@test "bash: no initial invocation with SET_TF_ALIAS_AUTOHOOK=0" {
  run bash -ic "
    shopt -s expand_aliases
    export SET_TF_ALIAS_AUTOHOOK=0
    cd '$TEST_TMP'
    source '$STF_LIB'
    alias tf 2>&1 || echo 'unset'
  "
  [[ "$output" == *"unset"* ]]
}

@test "bash: manual call still works when autohook=0" {
  run bash -ic "
    shopt -s expand_aliases
    export SET_TF_ALIAS_AUTOHOOK=0
    cd '$TEST_TMP'
    source '$STF_LIB'
    set_tf_alias
    alias tf
  "
  [[ "$output" == *"alias tf='tofu'"* ]]
}

@test "bash: non-interactive shell skips initial invocation" {
  run bash -c "
    shopt -s expand_aliases
    cd '$TEST_TMP'
    source '$STF_LIB'
    alias tf 2>&1 || echo 'unset'
  "
  [[ "$output" == *"unset"* ]]
}

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

@test "bash: PROMPT_COMMAND runs set_tf_alias when PWD changes" {
  mkdir -p "$TEST_TMP/project"
  echo "1.8.5" >"$TEST_TMP/project/.opentofu-version"
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB'
    cd '$TEST_TMP/project'
    # Simulate a prompt fire
    eval \"\$PROMPT_COMMAND\"
    alias tf
  "
  [[ "$output" == *"alias tf='tofu'"* ]]
}

@test "bash: PROMPT_COMMAND short-circuits on same PWD" {
  mkdir -p "$TEST_TMP/project"
  echo "1.8.5" >"$TEST_TMP/project/.opentofu-version"
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB'
    cd '$TEST_TMP/project'
    eval \"\$PROMPT_COMMAND\"   # first fire
    eval \"\$PROMPT_COMMAND\"   # second fire, same PWD
  " 2>&1
  # Only one success line should appear
  count=$(echo "$output" | grep -c 'set_tf_alias: tofu' || true)
  [ "$count" -eq 1 ]
}

@test "bash: PROMPT_COMMAND not wired when SET_TF_ALIAS_AUTOHOOK=0" {
  run bash -c "
    export SET_TF_ALIAS_AUTOHOOK=0
    source '$STF_LIB'
    echo \"prompt=[\$PROMPT_COMMAND]\"
  "
  [[ "$output" == *"prompt=[]"* ]]
}

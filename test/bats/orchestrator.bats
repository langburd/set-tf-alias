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

@test "version file wins: prints green success and sets tofu alias" {
  echo "1.8.5" >"$TEST_TMP/.opentofu-version"
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB'
    SET_TF_ALIAS_AUTOHOOK=0 set_tf_alias
    alias tf
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"set_tf_alias: tofu 1.8.5"* ]]
  [[ "$output" == *"alias tf='tofu'"* ]]
}

@test "lockfile fallback to opentofu is silent" {
  printf 'provider "registry.opentofu.org/x/y" { version = "1" }\n' \
    >"$TEST_TMP/.terraform.lock.hcl"
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB'
    SET_TF_ALIAS_AUTOHOOK=0 set_tf_alias 2>&1
    alias tf
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"alias tf='tofu'"* ]]
  [[ "$output" != *"set_tf_alias: tofu"* ]]
}

@test "tofu glob fallback (no version file, no lockfile)" {
  touch "$TEST_TMP/main.tofu"
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB'
    SET_TF_ALIAS_AUTOHOOK=0 set_tf_alias
    alias tf
  "
  [[ "$output" == *"alias tf='tofu'"* ]]
}

@test "nothing found: defaults to terraform alias, no output" {
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB'
    SET_TF_ALIAS_AUTOHOOK=0 set_tf_alias 2>&1
    alias tf
  "
  [[ "$output" == *"alias tf='terraform'"* ]]
  [[ "$output" != *"set_tf_alias:"* ]]
}

@test "tenv missing: warn once, fall back to bare binary" {
  echo "1.8.5" >"$TEST_TMP/.opentofu-version"
  run bash -c "
    shopt -s expand_aliases
    PATH=/usr/bin:/bin
    source '$STF_LIB'
    SET_TF_ALIAS_AUTOHOOK=0 set_tf_alias
    alias tf
  "
  [[ "$output" == *"tenv not installed"* ]]
  [[ "$output" == *"alias tf='tofu'"* ]]
}

@test "tenv install fails: red warning, fall back alias" {
  echo "1.8.5" >"$TEST_TMP/.opentofu-version"
  run bash -c "
    shopt -s expand_aliases
    STUB_TENV_FAIL=1 source '$STF_LIB'
    STUB_TENV_FAIL=1 SET_TF_ALIAS_AUTOHOOK=0 set_tf_alias
    alias tf
  "
  [[ "$output" == *"set_tf_alias: tenv failed"* ]]
  [[ "$output" == *"alias tf='tofu'"* ]]
}

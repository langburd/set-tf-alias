#!/usr/bin/env bats

load ../helpers

setup() {
  _tmpbase="${TMPDIR:-/tmp}"
  _tmpbase="${_tmpbase%/}"
  TEST_TMP="$(mktemp -d "${_tmpbase}/stf.XXXXXX")"
  export TEST_TMP
  # Mount the tenv stub on PATH
  export PATH="${BATS_TEST_DIRNAME}/../bin:$PATH"
  cd "$TEST_TMP" || return 1
}

teardown() {
  cd / || true
  rm -rf "$TEST_TMP"
}

@test "extracts version from tenv tofu detect output" {
  run bash -c "source '$STF_LIB'; __stf_run_tenv_detect tofu"
  [ "$status" -eq 0 ]
  [ "$output" = "1.8.5" ]
}

@test "extracts version from tenv tf detect output" {
  run bash -c "source '$STF_LIB'; __stf_run_tenv_detect tf"
  [ "$status" -eq 0 ]
  [ "$output" = "1.9.0" ]
}

@test "returns non-zero and surfaces stderr on tenv failure" {
  STUB_TENV_FAIL=1 run bash -c "source '$STF_LIB'; __stf_run_tenv_detect tofu"
  [ "$status" -ne 0 ]
  [[ "$output" == *"tenv: stub failure"* ]]
}

@test "works under zsh" {
  run zsh -c "source '$STF_LIB'; __stf_run_tenv_detect tofu"
  [ "$status" -eq 0 ]
  [ "$output" = "1.8.5" ]
}

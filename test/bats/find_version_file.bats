#!/usr/bin/env bats

load ../helpers

@test "returns empty when no version file on walk-up" {
  run stf_source_bash '__stf_find_version_file'
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "detects .opentofu-version in current directory" {
  echo "1.8.5" >"$TEST_TMP/.opentofu-version"
  run stf_source_bash '__stf_find_version_file'
  [ "$status" -eq 0 ]
  [ "$output" = "tofu:$TEST_TMP/.opentofu-version" ]
}

@test "detects .terraform-version in current directory" {
  echo "1.9.0" >"$TEST_TMP/.terraform-version"
  run stf_source_bash '__stf_find_version_file'
  [ "$status" -eq 0 ]
  [ "$output" = "tf:$TEST_TMP/.terraform-version" ]
}

@test "walks up to parent directory to find version file" {
  echo "1.8.5" >"$TEST_TMP/.opentofu-version"
  mkdir -p "$TEST_TMP/a/b/c"
  run bash -c "cd '$TEST_TMP/a/b/c'; source '$STF_LIB'; __stf_find_version_file"
  [ "$status" -eq 0 ]
  [ "$output" = "tofu:$TEST_TMP/.opentofu-version" ]
}

@test "nearest version file wins over ancestor" {
  echo "1.9.0" >"$TEST_TMP/.terraform-version"
  mkdir -p "$TEST_TMP/child"
  echo "1.8.5" >"$TEST_TMP/child/.opentofu-version"
  run bash -c "cd '$TEST_TMP/child'; source '$STF_LIB'; __stf_find_version_file"
  [ "$status" -eq 0 ]
  [ "$output" = "tofu:$TEST_TMP/child/.opentofu-version" ]
}

@test "works under zsh" {
  echo "1.8.5" >"$TEST_TMP/.opentofu-version"
  run stf_source_zsh '__stf_find_version_file'
  [ "$status" -eq 0 ]
  [ "$output" = "tofu:$TEST_TMP/.opentofu-version" ]
}

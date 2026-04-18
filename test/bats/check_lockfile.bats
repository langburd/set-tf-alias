#!/usr/bin/env bats

load ../helpers

@test "returns 1 when no lockfile present" {
  run bash -c "cd '$TEST_TMP'; source '$STF_LIB'; __stf_check_lockfile"
  [ "$status" -eq 1 ]
}

@test "returns 0 when lockfile contains registry.opentofu.org" {
  printf 'provider "registry.opentofu.org/hashicorp/aws" { version = "5.0.0" }\n' \
    >"$TEST_TMP/.terraform.lock.hcl"
  run bash -c "cd '$TEST_TMP'; source '$STF_LIB'; __stf_check_lockfile"
  [ "$status" -eq 0 ]
}

@test "returns 1 when lockfile contains only registry.terraform.io" {
  printf 'provider "registry.terraform.io/hashicorp/aws" { version = "5.0.0" }\n' \
    >"$TEST_TMP/.terraform.lock.hcl"
  run bash -c "cd '$TEST_TMP'; source '$STF_LIB'; __stf_check_lockfile"
  [ "$status" -eq 1 ]
}

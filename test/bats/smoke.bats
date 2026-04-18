#!/usr/bin/env bats

load ../helpers

@test "library sources cleanly under bash" {
  # shellcheck disable=SC2016
  run stf_source_bash 'echo "shell=$__STF_SHELL"'
  [ "$status" -eq 0 ]
  [ "$output" = "shell=bash" ]
}

@test "library sources cleanly under zsh" {
  # shellcheck disable=SC2016
  run stf_source_zsh 'echo "shell=$__STF_SHELL"'
  [ "$status" -eq 0 ]
  [ "$output" = "shell=zsh" ]
}

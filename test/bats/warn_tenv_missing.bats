#!/usr/bin/env bats

load ../helpers

@test "prints warning on first call, silent on second" {
  # shellcheck disable=SC2016
  run stf_source_bash '
    __stf_warn_tenv_missing 2>&1 >/dev/null
    __stf_warn_tenv_missing 2>&1 >/dev/null
    echo "---"
    [ "${_SET_TF_ALIAS_TENV_WARNED:-0}" = 1 ] && echo "guarded"
  '
  [ "$status" -eq 0 ]
  # First line is the warning; second invocation produces nothing.
  [[ "${lines[0]}" == *"tenv not installed"* ]]
  [ "${lines[1]}" = "---" ]
  [ "${lines[2]}" = "guarded" ]
}

@test "warning goes to stderr, not stdout" {
  run stf_source_bash '__stf_warn_tenv_missing 2>/dev/null'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

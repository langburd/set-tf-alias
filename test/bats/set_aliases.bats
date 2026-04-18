#!/usr/bin/env bats

load ../helpers

@test "sets tf/tfa/tfp/terraform/tofu aliases to the given binary (bash)" {
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB'
    __stf_set_aliases tofu
    alias tf
    alias tfp
    alias terraform
    alias tofu
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"alias tf='tofu'"* ]]
  [[ "$output" == *"alias tfp='tofu plan'"* ]]
  [[ "$output" == *"alias terraform='tofu'"* ]]
  [[ "$output" == *"alias tofu='tofu'"* ]]
}

@test "sets aliases under zsh" {
  run zsh -c "
    source '$STF_LIB'
    __stf_set_aliases terraform
    alias tf
    alias tfp
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"tf=terraform"* ]]
  [[ "$output" == *"tfp='terraform plan'"* ]]
}

@test "unsets aliases when called with empty binary" {
  run bash -c "
    shopt -s expand_aliases
    source '$STF_LIB'
    alias tf=preexisting
    __stf_set_aliases ''
    alias tf 2>&1 || echo 'unset'
  "
  [[ "$output" == *"unset"* ]]
}

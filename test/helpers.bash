# Shared helpers for set-tf-alias bats suite.

# Absolute path to the library under test.
: "${STF_LIB:=${BATS_TEST_DIRNAME}/../../set-tf-alias.sh}"

# Make a temp workspace per test; cleaned up in teardown.
setup() {
  local _tmpbase="${TMPDIR:-/tmp}"
  _tmpbase="${_tmpbase%/}"
  TEST_TMP="$(mktemp -d "$_tmpbase/stf.XXXXXX")"
  export TEST_TMP
  cd "$TEST_TMP" || return 1
}

teardown() {
  cd /
  rm -rf "$TEST_TMP"
}

# Source the library in a subshell with a clean env.
stf_source_bash() {
  bash -c "set -e; cd '$TEST_TMP'; source '$STF_LIB'; $*"
}

stf_source_zsh() {
  zsh -c "set -e; cd '$TEST_TMP'; source '$STF_LIB'; $*"
}

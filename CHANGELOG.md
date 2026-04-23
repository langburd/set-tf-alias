# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.1.2] - 2026-04-23

### Bug Fixes

* unset aliases when no terraform/tofu indicator found
* address code review findings (shellcheck warnings)

## [0.1.1] - 2026-04-18

### CI

* fix release workflow sha256 robustness and visibility
* compute sha256 from release tarball, not raw .sh file

## [0.1.0] - 2026-04-18

### Features

* add shell detection and bash version guard
* port `__stf_find_version_file` with walk-up detection
* port `__stf_check_lockfile`
* port `__stf_run_tenv_detect` with tenv stub for tests
* port `__stf_warn_tenv_missing` with `__stf_color` helper
* port `__stf_set_aliases` covering tf/tofu/terraform
* implement `set_tf_alias` orchestrator and `__stf_has_tofu_files`
* wire zsh `chpwd` hook gated by `SET_TF_ALIAS_AUTOHOOK`
* wire bash `PROMPT_COMMAND` hook with PWD gate
* initial invocation gated by autohook and interactivity
* add `SET_TF_ALIAS_DEBUG` and TTY-gated color output
* add curl | sh installer with idempotent rc append

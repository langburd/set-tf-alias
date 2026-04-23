# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0](https://github.com/langburd/set-tf-alias/compare/v0.1.2...v0.2.0) (2026-04-23)


### Features

* **ci:** add CI and release workflows for versioning ([d9ff12b](https://github.com/langburd/set-tf-alias/commit/d9ff12b279f8bf36833b336611852d163ee034dc))
* **docs:** add AI coding guidelines and verification steps ([a9f6523](https://github.com/langburd/set-tf-alias/commit/a9f6523823f093c1e621d26d454abcc2331c76ed))
* **install:** improve installer reliability and version tracking ([04fe050](https://github.com/langburd/set-tf-alias/commit/04fe050d9db531e27c11b7300270f0f09c4397ed))
* **install:** support version pinning via STF_TAG and improve version extraction ([e2f95c9](https://github.com/langburd/set-tf-alias/commit/e2f95c9348421f4549bd0ab8974e98619530e5d6))
* **install:** update installer to fetch latest version dynamically ([8bbe479](https://github.com/langburd/set-tf-alias/commit/8bbe479d0597b2516f4b54ae01ca50df67dc6586))
* migrate CLAUDE.md to AGENTS.md standard ([dd52a51](https://github.com/langburd/set-tf-alias/commit/dd52a512e29e7e67ce58b39846983871818461c1))


### Bug Fixes

* address code review findings ([54e0a80](https://github.com/langburd/set-tf-alias/commit/54e0a80a840ceeaebc587009aacd921fdce34b9d))
* **ci:** use PAT for release-please and skip no-commit-to-branch in CI ([de992de](https://github.com/langburd/set-tf-alias/commit/de992deada55ab0add3904dc0305210aa6593a47))
* **ci:** use PAT for release-please and skip no-commit-to-branch in CI ([cc18353](https://github.com/langburd/set-tf-alias/commit/cc18353ceb2010b0eb3f2439b3acb1ec96fd7ed7))
* **release:** upload set-tf-alias.sh as release asset ([d215676](https://github.com/langburd/set-tf-alias/commit/d2156766211efa0e16fcd3c95b452bdee3e812ea))

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

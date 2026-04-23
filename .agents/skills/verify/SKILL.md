---
name: verify
description: Run all pre-commit checks and BATS tests. Use before marking any change complete.
---

Run the full verification suite for this repository:

```bash
pre-commit run --all-files && bats test/bats/
```

Report any failures. If `pre-commit` is not installed, remind the user to run `pre-commit install` first.

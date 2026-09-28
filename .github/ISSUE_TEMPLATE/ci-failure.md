---
title: "🔴 CI is failing on main"
labels: ci-failure, bug
---

<!--
This title is intentionally stable (no run number/SHA) so that repeated CI
failures update this same issue (update_existing: true in the workflow)
instead of filing a new one every time main stays red.
-->

## What happened

The **{{ workflow }}** workflow failed on `main` (run #{{ env.RUN_NUMBER }}).

- **Failed job(s):** {{ env.FAILED_JOBS }}
- **Commit:** [`{{ sha }}`]({{ env.COMMIT_URL }}) — {{ env.COMMIT_MESSAGE }}
- **Triggered by:** {{ actor }}
- **Workflow run:** {{ env.RUN_URL }}

## Why this matters

`main` is supposed to always be in a working state — that's what the whole
point of running checks on every push is. Right now, either the code doesn't
format/analyze cleanly, a test is failing, or the Android build is broken,
which means anyone pulling `main` right now may not be able to build, test,
or ship the app until this is fixed.

## Next steps

1. Open the [failed run]({{ env.RUN_URL }}) and find the first red step —
   the log there has the actual error.
2. Reproduce locally:
   ```bash
   flutter pub get
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test
   flutter build apk --debug
   ```
3. Push a fix. If CI fails again on `main`, this same issue will be updated
   rather than a duplicate being filed — close it once a run goes green.

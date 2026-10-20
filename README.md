# Light Touch for macOS Big Sur

This branch is a port layer, not a copy of Light Touch. It holds only what turns an upstream
[Light Touch](https://github.com/samhenrigold/LightTouchMac) release tag into a build that runs on macOS 11
(Intel). CI checks out the upstream tag, applies this layer and builds; nothing here edits upstream history.

## Status

Phase 0 is the go/no-go check: can the Xcode on GitHub's macOS runners open the upstream project, and can it
target macOS 11? It isn't run yet.

- `spike/probe-toolchain.sh` records:
  - the Xcode version and its SDK's deployment-target range;
  - whether the back-deployed Swift concurrency library ships;
  - an async program built for `x86_64-apple-macos11.0`;
  - the SDK availability of the APIs the plan depends on.
- `spike/compile.sh` builds upstream twice, as is and with `MACOSX_DEPLOYMENT_TARGET=11.0`. It summarizes the
  errors by module and by unavailable API (`spike/summarize.py`).
- `.github/workflows/spike.yml` runs both on `macos-26` and `macos-15`. Start it from the Actions tab with
  **Run workflow**. The job summary and the `spike-*` artifacts are the result.

## Layout as it grows

| Path | What |
|---|---|
| `apply.sh`, `codemod.py`, `rules/` | Turn an upstream checkout into the Big Sur tree. Four steps: add files, copy forks over upstream paths, mechanical rewrites, then `git apply -3` the patches. |
| `add/` | New packages and files: BigSurCompat, ObservationCompat, the swift-subprocess and Sparkle stand-ins |
| `forks/` | Big Sur replacements for whole upstream files, each with the upstream blob it mirrors |
| `patches/` | Small hand patches, one topic each, written against the tree after the steps above |
| `check/` | Run on the Big Sur Mac against a built app. Checks every imported symbol and every Objective-C selector against the live system. |
| `install.sh` | On the Mac: graft the guest files from the official release of the same tag, sign ad hoc, run `check/` |

The guest files are the guest tools, SecureROMs and built-in iPod. CI never builds or ships them; `install.sh`
copies them from the official release on the Mac.

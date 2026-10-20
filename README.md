# Light Touch for macOS Big Sur

This branch is a port layer, not a copy of Light Touch. It holds only what turns an upstream
[Light Touch](https://github.com/samhenrigold/LightTouchMac) release tag into a build that runs on macOS 11
(Intel). CI checks out the upstream tag, applies this layer and builds; nothing here edits upstream history.

## Status

Phase 0 is the go/no-go check: which compiler builds upstream on a GitHub-hosted Mac, and can it target macOS 11?

Established on 2026-10-20 (macos-15, Xcode 26.3, Swift 6.2.4):
- **Targeting macOS 11 works.**
  - The SDK accepts deployment targets from 10.13 to 26.2.
  - The back-deployed `libswift_Concurrency.dylib` ships.
  - An async program built for `x86_64-apple-macos11.0` links it with minos 11.0.
- **APIs:**
  - `NSLocking.withLock` is `@_alwaysEmitIntoClient` and available from 10.10.
  - `NSSplitViewItem(inspectorWithViewController:)` is available from 11.0.
  - `CGWindowListCreateImage` is deprecated in 14 and obsoleted in 15, so it still works when targeting 11.
- **Project format:** Xcode 26 can't open upstream's objectVersion 110 (Xcode 27); with 77 it opens and builds.
- **Compiler gap:** upstream builds with Xcode 27 (Swift 6.4); GitHub's newest is Xcode 26.6 (Swift 6.3.3).
  - On Swift 6.2.4, unmodified upstream stops on about 20 errors the newer compiler accepts:
    - type-checker timeouts (`BootRecipe.swift:284,341`, `N45NOR.swift:177`);
    - an ambiguous `init` (`K48Recipe.swift:205`);
    - closure capture order (`DeviceLink.swift:268`);
    - region-isolation checks (`HostServiceWorkers.swift:177`, `MediaSong.swift:188`).
  - They become small compiler-compatibility patches.
  - swift.org's 6.4.1 toolchain was tried and dropped. Xcode can't link package manifests with it, it ships no
    back-deployed concurrency library, and its standard library is built for macOS 13.
- **Build environment (run 39500162968): Xcode 26.6 (Swift 6.3.3, macOS 26.5 SDK) on `macos-26`.**
  - It ships the back-deployed concurrency library.
  - Unmodified upstream stops on only two Swift errors there: `DeviceLink.swift:268`, a closure that captures
    `channel` before it's declared, and `K48Recipe.swift:205`, an ambiguous `init`.
  - Its `actool` throws on `LightTouch.icon` (Icon Composer, Xcode 27).
  - Those three become compiler-compatibility patches.
  - Full results are on the `ci-results` branch; read them with `spike/fetch-results.sh RUN_ID`.

- `spike/probe-toolchain.sh` records:
  - the Xcode version and its SDK's deployment-target range;
  - whether the back-deployed Swift concurrency library ships;
  - an async program built for `x86_64-apple-macos11.0`;
  - the SDK availability of the APIs the plan depends on.
- `spike/compile.sh` builds upstream twice, as is and with `MACOSX_DEPLOYMENT_TARGET=11.0`. It summarizes the
  errors by module and by unavailable API (`spike/summarize.py`).
- `.github/workflows/spike.yml` runs both on `macos-26` and `macos-15`. Start it from the Actions tab with
  **Run workflow**. The job summary and the `spike-*` artifacts are the result.

## The feedback loop

`.github/workflows/port.yml` runs on every push to this branch, or by hand for a given upstream tag.
- **`compat`:** builds the compat packages with Xcode 26.6, runs their checks and ObservationCompat's macro tests.
- **`compile`:** applies the port to the newest upstream release and compiles it for macOS 11.
- **Results:** in the `ci-results` branch (`spike/fetch-results.sh RUN_ID`).
- **On the Big Sur Mac:** `check/compat.sh --display` runs the same compat checks there, the real target.

## Applying the port

`apply.sh UPSTREAM_CHECKOUT` turns a fresh upstream checkout into the Big Sur tree, on a new
`bigsur-applied-<sha>` branch of that checkout.
- Use a checkout you can throw away (CI's, or `git clone --no-checkout` plus `git checkout <tag>`). Never use
  your working copy of upstream.
- It commits steps 1–3 and the hand patches separately, so `git diff HEAD~1` shows the patches.
- `codemod.py` prints each rule's count and fails when a required rule matches nothing, which means upstream
  moved what that rule rewrites.

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

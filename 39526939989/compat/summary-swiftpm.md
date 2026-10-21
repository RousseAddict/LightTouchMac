Building for debugging...
[0/9] Write sources
[0/9] Write compat-checks-entitlement.plist
[2/9] Write sources
[3/9] Write swift-version-7974D3F7F03D5E95.txt
[5/16] Compiling BigSurCompat CompatFormat.swift
[6/16] Compiling BigSurCompat CompatLocale.swift
[7/16] Compiling BigSurCompat CompatRegex.swift
[8/19] Emitting module BigSurCompat
[9/19] Compiling BigSurCompat CompatClocks.swift
[10/19] Compiling BigSurCompat CompatDisplayLink.swift
[11/19] Compiling BigSurCompat CompatDuration.swift
[12/19] Compiling BigSurCompat CompatUnfairLock.swift
[13/19] Compiling BigSurCompat FoundationCompat.swift
[14/19] Compiling BigSurCompat URLSessionCompat.swift
[14/19] Write Objects.LinkFileList
[15/19] Archiving libBigSurCompat.a
[17/21] Emitting module compat_checks
[18/21] Compiling compat_checks Checks.swift
[18/21] Write Objects.LinkFileList
[19/21] Linking compat-checks
[20/21] Applying compat-checks
Build complete! (9.99s)
Building for debugging...
[0/10] Write sources
[0/10] Write subprocess-checks-entitlement.plist
[0/10] Write sources
[4/10] Write swift-version-7974D3F7F03D5E95.txt
[6/17] Compiling BigSurCompat CompatClocks.swift
[7/17] Compiling BigSurCompat CompatDisplayLink.swift
[8/17] Compiling BigSurCompat CompatDuration.swift
[9/17] Compiling BigSurCompat CompatFormat.swift
[10/17] Compiling BigSurCompat CompatLocale.swift
[11/17] Compiling BigSurCompat CompatRegex.swift
[12/17] Emitting module BigSurCompat
[13/20] Compiling BigSurCompat CompatUnfairLock.swift
[14/20] Compiling BigSurCompat FoundationCompat.swift
[15/20] Compiling BigSurCompat URLSessionCompat.swift
[15/20] Write Objects.LinkFileList
[16/20] Archiving libBigSurCompat.a
[18/25] Compiling Subprocess IO.swift
[19/25] Compiling Subprocess Run.swift
[20/26] Emitting module Subprocess
[21/26] Compiling Subprocess Configuration.swift
[22/26] Compiling Subprocess Execution.swift
[23/26] Compiling Subprocess Spawn.swift
[24/28] Compiling subprocess_checks Checks.swift
[25/28] Emitting module subprocess_checks
[25/28] Write Objects.LinkFileList
[26/28] Linking subprocess-checks
[27/28] Applying subprocess-checks
Build complete! (14.17s)
Building for debugging...
[0/2] Write sources
[1/2] Write swift-version-7974D3F7F03D5E95.txt
[3/4] Compiling Sparkle SPUStandardUpdaterController.swift
[4/4] Emitting module Sparkle
Build complete! (15.79s)
Fetching https://github.com/swiftlang/swift-syntax.git
[1/80976] Fetching swift-syntax
Fetched https://github.com/swiftlang/swift-syntax.git from cache (5.98s)
Computing version for https://github.com/swiftlang/swift-syntax.git
Computed https://github.com/swiftlang/swift-syntax.git at 602.0.0 (7.16s)
Creating working copy for https://github.com/swiftlang/swift-syntax.git
Working copy of https://github.com/swiftlang/swift-syntax.git resolved at 602.0.0
Downloading package prebuilt https://download.swift.org/prebuilts/swift-syntax/602.0.0/swiftlang-6.3.3.1.3-macosx26.5-MacroSupport.zip
Downloaded https://download.swift.org/prebuilts/swift-syntax/602.0.0/swiftlang-6.3.3.1.3-macosx26.5-MacroSupport.zip (1.01s)
Building for debugging...
[0/17] /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/.build/arm64-apple-macosx/debug/ObservationCompatPackageTests.derived/runner.swift
[1/17] Write sources
[2/17] Write observation-checks-entitlement.plist
[3/17] Write sources
[7/17] Write swift-version-7974D3F7F03D5E95.txt
[9/21] Compiling ObservationCompatMacros ObservableMacro.swift
[10/21] Emitting module ObservationCompatMacros
[11/21] Compiling ObservationCompatMacros Availability.swift
[12/21] Compiling ObservationCompatMacros Extensions.swift
[13/22] Compiling ObservationCompatMacros Plugin.swift
[13/22] Write Objects.LinkFileList
[14/22] Linking ObservationCompatMacros-tool
[16/27] Compiling ObservationCompat Locking.swift
[17/27] Compiling ObservationCompat Observable.swift
[18/27] Compiling ObservationCompat ObservationRegistrar.swift
[19/27] Compiling ObservationCompat ObservationTracking.swift
[20/27] Emitting module ObservationCompat
Internal Error: DecodingError.dataCorrupted: Data was corrupted. Debug description: Corrupted JSON. Underlying error: unexpected end of file
[21/28] Compiling ObservationCompat ThreadLocal.swift
[21/28] Write Objects.LinkFileList
[22/28] Archiving libObservationCompat.a
[24/32] Compiling ObservationCompatTests ObservationCompatTests.swift
[25/32] Emitting module ObservationCompatTests
[26/32] Compiling observation_checks Checks.swift
/Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Sources/observation-checks/Checks.swift:168:18: warning: weak variable 'weakModel' was never mutated; consider changing to 'let' constant [#WeakMutability]
166 | 
167 |         var tracked: Model? = Model()
168 |         weak var weakModel = tracked
    |                  `- warning: weak variable 'weakModel' was never mutated; consider changing to 'let' constant [#WeakMutability]
169 |         withCompatObservationTracking { _ = tracked?.count } onChange: { box.fired += 1 }
170 |         tracked = nil

[#WeakMutability]: <https://docs.swift.org/compiler/documentation/diagnostics/weak-mutability>
[27/32] Emitting module observation_checks
[27/32] Write Objects.LinkFileList
[29/34] Compiling ObservationCompatPackageTests runner.swift
[30/34] Emitting module ObservationCompatPackageTests
[30/34] Write Objects.LinkFileList
[31/34] Linking observation-checks
[32/34] Applying observation-checks
[33/34] Linking ObservationCompatPackageTests
Build complete! (24.35s)
Test Suite 'All tests' started at 2026-10-21 01:24:57.476.
Test Suite 'All tests' passed at 2026-10-21 01:24:57.481.
	 Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.006) seconds
◇ Test run started.
↳ Testing Library Version: 1902
↳ Target Platform: arm64e-apple-macos14.0
◇ Suite ObservationCompatTests started.
◇ Test aMainActorModelIsObservable() started.
◇ Test aHandAnnouncedMutationFires() started.
◇ Test anEqualWriteIsSilent() started.
◇ Test aChangeToAReadPropertyFiresOnce() started.
◇ Test aComputedPropertyIsTrackedThroughItsStorage() started.
◇ Test anIgnoredPropertyIsntTracked() started.
◇ Test theMacroAddsTheConformance() started.
✔ Test aComputedPropertyIsTrackedThroughItsStorage() passed after 0.001 seconds.
✔ Test anEqualWriteIsSilent() passed after 0.001 seconds.
✔ Test aHandAnnouncedMutationFires() passed after 0.001 seconds.
✔ Test anIgnoredPropertyIsntTracked() passed after 0.001 seconds.
✔ Test theMacroAddsTheConformance() passed after 0.001 seconds.
✔ Test aChangeToAReadPropertyFiresOnce() passed after 0.001 seconds.
✔ Test aMainActorModelIsObservable() passed after 0.001 seconds.
✔ Suite ObservationCompatTests passed after 0.001 seconds.
✔ Test run with 7 tests in 1 suite passed after 0.001 seconds.

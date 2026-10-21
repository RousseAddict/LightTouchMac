Building for debugging...
[0/9] Write sources
[0/9] Write compat-checks-entitlement.plist
[3/9] Write swift-version-7974D3F7F03D5E95.txt
[5/17] Compiling BigSurCompat CompatClocks.swift
[6/17] Compiling BigSurCompat CompatDisplayLink.swift
[7/17] Compiling BigSurCompat CompatDuration.swift
[8/17] Compiling BigSurCompat CompatRegex.swift
[9/17] Compiling BigSurCompat CompatUnfairLock.swift
[10/17] Emitting module BigSurCompat
[11/17] Compiling BigSurCompat CompatFormat.swift
[12/17] Compiling BigSurCompat CompatLocale.swift
[13/19] Compiling BigSurCompat FoundationCompat.swift
[14/19] Compiling BigSurCompat URLSessionCompat.swift
[14/19] Write Objects.LinkFileList
[15/19] Archiving libBigSurCompat.a
[17/21] Emitting module compat_checks
[18/21] Compiling compat_checks Checks.swift
[18/21] Write Objects.LinkFileList
[19/21] Linking compat-checks
[20/21] Applying compat-checks
Build complete! (10.15s)
Building for debugging...
[0/10] Write sources
[0/10] Write subprocess-checks-entitlement.plist
[3/10] Write sources
[4/10] Write swift-version-7974D3F7F03D5E95.txt
[6/18] Compiling BigSurCompat CompatRegex.swift
[7/18] Compiling BigSurCompat CompatUnfairLock.swift
[8/18] Compiling BigSurCompat CompatFormat.swift
[9/18] Compiling BigSurCompat CompatLocale.swift
[10/20] Compiling BigSurCompat CompatClocks.swift
[11/20] Compiling BigSurCompat CompatDisplayLink.swift
[12/20] Compiling BigSurCompat CompatDuration.swift
[13/20] Emitting module BigSurCompat
[14/20] Compiling BigSurCompat FoundationCompat.swift
[15/20] Compiling BigSurCompat URLSessionCompat.swift
[15/20] Write Objects.LinkFileList
[16/20] Archiving libBigSurCompat.a
[18/25] Compiling Subprocess Run.swift
[19/26] Compiling Subprocess IO.swift
[20/26] Emitting module Subprocess
[21/26] Compiling Subprocess Configuration.swift
[22/26] Compiling Subprocess Execution.swift
[23/26] Compiling Subprocess Spawn.swift
[24/28] Emitting module subprocess_checks
[25/28] Compiling subprocess_checks Checks.swift
[25/28] Write Objects.LinkFileList
[26/28] Linking subprocess-checks
[27/28] Applying subprocess-checks
Build complete! (10.71s)
Building for debugging...
[0/2] Write sources
[1/2] Write swift-version-7974D3F7F03D5E95.txt
[3/4] Emitting module Sparkle
[4/4] Compiling Sparkle SPUStandardUpdaterController.swift
Build complete! (12.49s)
Fetching https://github.com/swiftlang/swift-syntax.git
[1/80991] Fetching swift-syntax
Fetched https://github.com/swiftlang/swift-syntax.git from cache (6.81s)
Computing version for https://github.com/swiftlang/swift-syntax.git
Computed https://github.com/swiftlang/swift-syntax.git at 602.0.0 (7.72s)
Creating working copy for https://github.com/swiftlang/swift-syntax.git
Working copy of https://github.com/swiftlang/swift-syntax.git resolved at 602.0.0
Downloading package prebuilt https://download.swift.org/prebuilts/swift-syntax/602.0.0/swiftlang-6.3.3.1.3-macosx26.5-MacroSupport.zip
Downloaded https://download.swift.org/prebuilts/swift-syntax/602.0.0/swiftlang-6.3.3.1.3-macosx26.5-MacroSupport.zip (1.09s)
Building for debugging...
[0/17] /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/.build/x86_64-apple-macosx/debug/ObservationCompatPackageTests.derived/runner.swift
[0/17] Write sources
[2/17] Write observation-checks-entitlement.plist
[4/17] Write sources
[7/17] Write swift-version-7974D3F7F03D5E95.txt
[9/21] Compiling ObservationCompatMacros Availability.swift
[10/21] Compiling ObservationCompatMacros Extensions.swift
[11/21] Emitting module ObservationCompatMacros
[12/21] Compiling ObservationCompatMacros ObservableMacro.swift
[13/22] Compiling ObservationCompatMacros Plugin.swift
[13/22] Write Objects.LinkFileList
[14/22] Linking ObservationCompatMacros-tool
[16/27] Compiling ObservationCompat Locking.swift
[17/27] Compiling ObservationCompat Observable.swift
[18/27] Compiling ObservationCompat ObservationRegistrar.swift
[19/27] Emitting module ObservationCompat
[20/27] Compiling ObservationCompat ObservationTracking.swift
[21/28] Compiling ObservationCompat ThreadLocal.swift
[21/28] Write Objects.LinkFileList
[22/28] Archiving libObservationCompat.a
[24/32] Emitting module ObservationCompatTests
[25/32] Compiling ObservationCompatTests ObservationCompatTests.swift
[26/34] Compiling ObservationCompatPackageTests runner.swift
[27/34] Emitting module ObservationCompatPackageTests
[27/34] Write Objects.LinkFileList
[28/34] Linking ObservationCompatPackageTests
[30/34] Emitting module observation_checks
[31/34] Compiling observation_checks Checks.swift
/Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Sources/observation-checks/Checks.swift:168:18: warning: weak variable 'weakModel' was never mutated; consider changing to 'let' constant [#WeakMutability]
166 | 
167 |         var tracked: Model? = Model()
168 |         weak var weakModel = tracked
    |                  `- warning: weak variable 'weakModel' was never mutated; consider changing to 'let' constant [#WeakMutability]
169 |         withCompatObservationTracking { _ = tracked?.count } onChange: { box.fired += 1 }
170 |         tracked = nil

[#WeakMutability]: <https://docs.swift.org/compiler/documentation/diagnostics/weak-mutability>
[31/34] Write Objects.LinkFileList
[32/34] Linking observation-checks
[33/34] Applying observation-checks
Build complete! (21.92s)
Test Suite 'All tests' started at 2026-10-21 16:59:24.206.
Test Suite 'All tests' passed at 2026-10-21 16:59:24.210.
	 Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.004) seconds
◇ Test run started.
↳ Testing Library Version: 1902
↳ Target Platform: x86_64-apple-macos14.0
◇ Suite ObservationCompatTests started.
◇ Test anEqualWriteIsSilent() started.
◇ Test anIgnoredPropertyIsntTracked() started.
◇ Test aMainActorModelIsObservable() started.
◇ Test aChangeToAReadPropertyFiresOnce() started.
◇ Test theMacroAddsTheConformance() started.
◇ Test aComputedPropertyIsTrackedThroughItsStorage() started.
◇ Test aHandAnnouncedMutationFires() started.
✔ Test aChangeToAReadPropertyFiresOnce() passed after 0.001 seconds.
✔ Test anIgnoredPropertyIsntTracked() passed after 0.001 seconds.
✔ Test anEqualWriteIsSilent() passed after 0.001 seconds.
✔ Test aComputedPropertyIsTrackedThroughItsStorage() passed after 0.001 seconds.
✔ Test theMacroAddsTheConformance() passed after 0.001 seconds.
✔ Test aMainActorModelIsObservable() passed after 0.001 seconds.
✔ Test aHandAnnouncedMutationFires() passed after 0.001 seconds.
✔ Suite ObservationCompatTests passed after 0.002 seconds.
✔ Test run with 7 tests in 1 suite passed after 0.002 seconds.

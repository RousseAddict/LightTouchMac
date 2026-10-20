Building for debugging...
[0/9] Write sources
[2/9] Write compat-checks-entitlement.plist
[3/9] Write swift-version-7974D3F7F03D5E95.txt
[5/14] Compiling BigSurCompat CompatDuration.swift
[6/14] Compiling BigSurCompat CompatUnfairLock.swift
[7/15] Emitting module BigSurCompat
[8/15] Compiling BigSurCompat CompatClocks.swift
[9/15] Compiling BigSurCompat CompatDisplayLink.swift
[10/15] Compiling BigSurCompat FoundationCompat.swift
[10/15] Write Objects.LinkFileList
[11/15] Archiving libBigSurCompat.a
[13/17] Compiling compat_checks Checks.swift
[14/17] Emitting module compat_checks
[14/17] Write Objects.LinkFileList
[15/17] Linking compat-checks
[16/17] Applying compat-checks
Build complete! (8.51s)
Building for debugging...
[0/10] Write subprocess-checks-entitlement.plist
[0/10] Write sources
[4/10] Write swift-version-7974D3F7F03D5E95.txt
[6/15] Compiling BigSurCompat CompatClocks.swift
[7/15] Compiling BigSurCompat CompatDisplayLink.swift
[8/15] Emitting module BigSurCompat
[9/15] Compiling BigSurCompat CompatDuration.swift
[10/15] Compiling BigSurCompat CompatUnfairLock.swift
[11/16] Compiling BigSurCompat FoundationCompat.swift
[11/16] Write Objects.LinkFileList
[12/16] Archiving libBigSurCompat.a
[14/21] Compiling Subprocess IO.swift
[15/21] Compiling Subprocess Run.swift
[16/21] Emitting module Subprocess
[17/21] Compiling Subprocess Configuration.swift
[18/21] Compiling Subprocess Execution.swift
[19/22] Compiling Subprocess Spawn.swift
[20/24] Emitting module subprocess_checks
[21/24] Compiling subprocess_checks Checks.swift
[21/24] Write Objects.LinkFileList
[22/24] Linking subprocess-checks
[23/24] Applying subprocess-checks
Build complete! (8.77s)
Building for debugging...
[0/2] Write sources
[1/2] Write swift-version-7974D3F7F03D5E95.txt
[3/4] Emitting module Sparkle
[4/4] Compiling Sparkle SPUStandardUpdaterController.swift
Build complete! (8.75s)
Fetching https://github.com/swiftlang/swift-syntax.git
[1/80976] Fetching swift-syntax
Fetched https://github.com/swiftlang/swift-syntax.git from cache (4.53s)
Computing version for https://github.com/swiftlang/swift-syntax.git
Computed https://github.com/swiftlang/swift-syntax.git at 602.0.0 (5.35s)
Creating working copy for https://github.com/swiftlang/swift-syntax.git
Working copy of https://github.com/swiftlang/swift-syntax.git resolved at 602.0.0
Downloading package prebuilt https://download.swift.org/prebuilts/swift-syntax/602.0.0/swiftlang-6.3.3.1.3-macosx26.5-MacroSupport.zip
Downloaded https://download.swift.org/prebuilts/swift-syntax/602.0.0/swiftlang-6.3.3.1.3-macosx26.5-MacroSupport.zip (0.65s)
Building for debugging...
[0/17] /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/.build/arm64-apple-macosx/debug/ObservationCompatPackageTests.derived/runner.swift
[1/17] Write sources
[2/17] Write observation-checks-entitlement.plist
[2/17] Write sources
[7/17] Write swift-version-7974D3F7F03D5E95.txt
[9/21] Compiling ObservationCompatMacros Availability.swift
[10/21] Compiling ObservationCompatMacros Extensions.swift
[11/21] Compiling ObservationCompatMacros ObservableMacro.swift
[12/21] Emitting module ObservationCompatMacros
[13/22] Compiling ObservationCompatMacros Plugin.swift
[13/22] Write Objects.LinkFileList
[14/22] Linking ObservationCompatMacros-tool
[16/27] Compiling ObservationCompat ObservationRegistrar.swift
[17/27] Compiling ObservationCompat ObservationTracking.swift
[18/27] Emitting module ObservationCompat
[19/27] Compiling ObservationCompat Locking.swift
[20/27] Compiling ObservationCompat Observable.swift
[21/28] Compiling ObservationCompat ThreadLocal.swift
[21/28] Write Objects.LinkFileList
[22/28] Archiving libObservationCompat.a
error: emit-module command failed with exit code 1 (use -v to see invocation)
[24/32] Emitting module ObservationCompatTests
macro expansion @CompatObservationTracked:1:40: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:8:18: note: expanded code originates here
  6 | @CompatObservable
  7 | final class Car {
  8 |     var name = ""
    +--- macro expansion @CompatObservationTracked ---------------------
    |1 | @CompatObservationIgnored private  var _name  = ""
    |  |                                        `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    +-------------------------------------------------------------------
  9 |     var miles = 0
 10 |     @CompatObservationIgnored var cache = 0

macro expansion @CompatObservationTracked:1:40: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:9:18: note: expanded code originates here
  7 | final class Car {
  8 |     var name = ""
  9 |     var miles = 0
    +--- macro expansion @CompatObservationTracked ---------------------
    |1 | @CompatObservationIgnored private  var _miles  = 0
    |  |                                        `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    +-------------------------------------------------------------------
 10 |     @CompatObservationIgnored var cache = 0
 11 |     var label: String { "\(name) \(miles)" }

/Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:10:35: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
  8 |     var name = ""
  9 |     var miles = 0
 10 |     @CompatObservationIgnored var cache = 0
    |                                   `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
 11 |     var label: String { "\(name) \(miles)" }
 12 | }

macro expansion @CompatObservable:1:39: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:12:1: note: expanded code originates here
  4 | import Testing
  5 | 
  6 | @CompatObservable
    | `- note: in expansion of macro 'CompatObservable' on class 'Car' here
  7 | final class Car {
  8 |     var name = ""
    :
 10 |     @CompatObservationIgnored var cache = 0
 11 |     var label: String { "\(name) \(miles)" }
 12 | }
    +--- macro expansion @CompatObservable -----------------------------
    | 1 | @CompatObservationIgnored private let _$observationRegistrar = ObservationCompat.CompatObservationRegistrar()
    |   |                                       `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    | 2 | 
    | 3 | internal nonisolated func access<$s22ObservationCompatTests3Car0B10ObservablefMm_6MemberfMu_>(
    +-------------------------------------------------------------------
 13 | 
 14 | /// EmulatorController's storageFailed: a computed property announced by hand.

/Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:17:35: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
 15 | @CompatObservable
 16 | final class Liveness {
 17 |     @CompatObservationIgnored var raw = false
    |                                   `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
 18 | 
 19 |     var storageFailed: Bool {

macro expansion @CompatObservable:1:39: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:28:1: note: expanded code originates here
 13 | 
 14 | /// EmulatorController's storageFailed: a computed property announced by hand.
 15 | @CompatObservable
    | `- note: in expansion of macro 'CompatObservable' on class 'Liveness' here
 16 | final class Liveness {
 17 |     @CompatObservationIgnored var raw = false
    :
 26 |         raw.toggle()
 27 |     }
 28 | }
    +--- macro expansion @CompatObservable -----------------------------
    | 1 | @CompatObservationIgnored private let _$observationRegistrar = ObservationCompat.CompatObservationRegistrar()
    |   |                                       `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    | 2 | 
    | 3 | internal nonisolated func access<$s22ObservationCompatTests8Liveness0B10ObservablefMm_6MemberfMu_>(
    +-------------------------------------------------------------------
 29 | 
 30 | /// Upstream's models are main-actor (LightTouchCore and the app default to it).

macro expansion @CompatObservationTracked:1:40: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:34:18: note: expanded code originates here
 32 | @CompatObservable
 33 | final class MainActorModel {
 34 |     var value = 0
    +--- macro expansion @CompatObservationTracked ---------------------
    |1 | @CompatObservationIgnored private  var _value  = 0
    |  |                                        `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    +-------------------------------------------------------------------
 35 | }
 36 | 

macro expansion @CompatObservable:1:39: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:35:1: note: expanded code originates here
 30 | /// Upstream's models are main-actor (LightTouchCore and the app default to it).
 31 | @MainActor
 32 | @CompatObservable
    | `- note: in expansion of macro 'CompatObservable' on class 'MainActorModel' here
 33 | final class MainActorModel {
 34 |     var value = 0
 35 | }
    +--- macro expansion @CompatObservable -----------------------------
    | 1 | @CompatObservationIgnored private let _$observationRegistrar = ObservationCompat.CompatObservationRegistrar()
    |   |                                       `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    | 2 | 
    | 3 | internal nonisolated func access<$s22ObservationCompatTests14MainActorModel0B10ObservablefMm_6MemberfMu_>(
    +-------------------------------------------------------------------
 36 | 
 37 | final class Fired: @unchecked Sendable {
[25/32] Compiling ObservationCompatTests ObservationCompatTests.swift
macro expansion @CompatObservationTracked:1:40: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:8:18: note: expanded code originates here
  6 | @CompatObservable
  7 | final class Car {
  8 |     var name = ""
    +--- macro expansion @CompatObservationTracked ---------------------
    |1 | @CompatObservationIgnored private  var _name  = ""
    |  |                                        `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    +-------------------------------------------------------------------
  9 |     var miles = 0
 10 |     @CompatObservationIgnored var cache = 0

macro expansion @CompatObservationTracked:1:40: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:9:18: note: expanded code originates here
  7 | final class Car {
  8 |     var name = ""
  9 |     var miles = 0
    +--- macro expansion @CompatObservationTracked ---------------------
    |1 | @CompatObservationIgnored private  var _miles  = 0
    |  |                                        `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    +-------------------------------------------------------------------
 10 |     @CompatObservationIgnored var cache = 0
 11 |     var label: String { "\(name) \(miles)" }

/Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:10:35: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
  8 |     var name = ""
  9 |     var miles = 0
 10 |     @CompatObservationIgnored var cache = 0
    |                                   `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
 11 |     var label: String { "\(name) \(miles)" }
 12 | }

macro expansion @CompatObservable:1:39: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:12:1: note: expanded code originates here
  4 | import Testing
  5 | 
  6 | @CompatObservable
    | `- note: in expansion of macro 'CompatObservable' on class 'Car' here
  7 | final class Car {
  8 |     var name = ""
    :
 10 |     @CompatObservationIgnored var cache = 0
 11 |     var label: String { "\(name) \(miles)" }
 12 | }
    +--- macro expansion @CompatObservable -----------------------------
    | 1 | @CompatObservationIgnored private let _$observationRegistrar = ObservationCompat.CompatObservationRegistrar()
    |   |                                       `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    | 2 | 
    | 3 | internal nonisolated func access<$s22ObservationCompatTests3Car0B10ObservablefMm_6MemberfMu_>(
    +-------------------------------------------------------------------
 13 | 
 14 | /// EmulatorController's storageFailed: a computed property announced by hand.

/Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:17:35: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
 15 | @CompatObservable
 16 | final class Liveness {
 17 |     @CompatObservationIgnored var raw = false
    |                                   `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
 18 | 
 19 |     var storageFailed: Bool {

macro expansion @CompatObservable:1:39: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:28:1: note: expanded code originates here
 13 | 
 14 | /// EmulatorController's storageFailed: a computed property announced by hand.
 15 | @CompatObservable
    | `- note: in expansion of macro 'CompatObservable' on class 'Liveness' here
 16 | final class Liveness {
 17 |     @CompatObservationIgnored var raw = false
    :
 26 |         raw.toggle()
 27 |     }
 28 | }
    +--- macro expansion @CompatObservable -----------------------------
    | 1 | @CompatObservationIgnored private let _$observationRegistrar = ObservationCompat.CompatObservationRegistrar()
    |   |                                       `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    | 2 | 
    | 3 | internal nonisolated func access<$s22ObservationCompatTests8Liveness0B10ObservablefMm_6MemberfMu_>(
    +-------------------------------------------------------------------
 29 | 
 30 | /// Upstream's models are main-actor (LightTouchCore and the app default to it).

macro expansion @CompatObservationTracked:1:40: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:34:18: note: expanded code originates here
 32 | @CompatObservable
 33 | final class MainActorModel {
 34 |     var value = 0
    +--- macro expansion @CompatObservationTracked ---------------------
    |1 | @CompatObservationIgnored private  var _value  = 0
    |  |                                        `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    +-------------------------------------------------------------------
 35 | }
 36 | 

macro expansion @CompatObservable:1:39: error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
`- /Users/runner/work/LightTouchMac/LightTouchMac/add/Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift:35:1: note: expanded code originates here
 30 | /// Upstream's models are main-actor (LightTouchCore and the app default to it).
 31 | @MainActor
 32 | @CompatObservable
    | `- note: in expansion of macro 'CompatObservable' on class 'MainActorModel' here
 33 | final class MainActorModel {
 34 |     var value = 0
 35 | }
    +--- macro expansion @CompatObservable -----------------------------
    | 1 | @CompatObservationIgnored private let _$observationRegistrar = ObservationCompat.CompatObservationRegistrar()
    |   |                                       `- error: expansion of macro 'CompatObservationIgnored()' did not produce a non-observing accessor (such as 'get') as expected
    | 2 | 
    | 3 | internal nonisolated func access<$s22ObservationCompatTests14MainActorModel0B10ObservablefMm_6MemberfMu_>(
    +-------------------------------------------------------------------
 36 | 
 37 | final class Fired: @unchecked Sendable {
[26/32] Emitting module observation_checks
error: fatalError

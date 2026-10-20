Applying the Big Sur port to /Users/runner/work/LightTouchMac/LightTouchMac/src (660c4a55) on branch bigsur-applied-660c4a55
== 1. add
  Packages/BigSur/Sparkle/Package.swift
  Packages/BigSur/Sparkle/Sources/Sparkle/SPUStandardUpdaterController.swift
  Packages/BigSur/swift-subprocess/Package.swift
  Packages/BigSur/swift-subprocess/Sources/subprocess-checks/Checks.swift
  Packages/BigSur/swift-subprocess/Sources/Subprocess/Configuration.swift
  Packages/BigSur/swift-subprocess/Sources/Subprocess/Execution.swift
  Packages/BigSur/swift-subprocess/Sources/Subprocess/IO.swift
  Packages/BigSur/swift-subprocess/Sources/Subprocess/Run.swift
  Packages/BigSur/swift-subprocess/Sources/Subprocess/Spawn.swift
  Packages/BigSurCompat/Package.swift
  Packages/BigSurCompat/Sources/BigSurCompat/CompatClocks.swift
  Packages/BigSurCompat/Sources/BigSurCompat/CompatDisplayLink.swift
  Packages/BigSurCompat/Sources/BigSurCompat/CompatDuration.swift
  Packages/BigSurCompat/Sources/BigSurCompat/CompatUnfairLock.swift
  Packages/BigSurCompat/Sources/BigSurCompat/FoundationCompat.swift
  Packages/BigSurCompat/Sources/compat-checks/Checks.swift
  Packages/DeviceServices/Sources/HostServiceWire/BigSurExports.swift
  Packages/HostRuntime/Sources/HostRuntime/BigSurExports.swift
  Packages/ObservationCompat/Package.swift
  Packages/ObservationCompat/Sources/observation-checks/Checks.swift
  Packages/ObservationCompat/Sources/ObservationCompat/Locking.swift
  Packages/ObservationCompat/Sources/ObservationCompat/Observable.swift
  Packages/ObservationCompat/Sources/ObservationCompat/ObservationRegistrar.swift
  Packages/ObservationCompat/Sources/ObservationCompat/ObservationTracking.swift
  Packages/ObservationCompat/Sources/ObservationCompat/ThreadLocal.swift
  Packages/ObservationCompat/Sources/ObservationCompatMacros/Availability.swift
  Packages/ObservationCompat/Sources/ObservationCompatMacros/Extensions.swift
  Packages/ObservationCompat/Sources/ObservationCompatMacros/ObservableMacro.swift
  Packages/ObservationCompat/Sources/ObservationCompatMacros/Plugin.swift
  Packages/ObservationCompat/Tests/ObservationCompatTests/ObservationCompatTests.swift
== 2. forks
== 3. codemod
    1  xcconfig: macOS 11
    4  project: macOS 11
    1  project: objectVersion 77
    1  project: swift-subprocess as a local package
    1  project: Sparkle as a local package
   33  swift: Duration
   49  swift: ContinuousClock
    6  swift: SuspendingClock
  182  swift: Task.sleep(for:)
   13  swift: OSAllocatedUnfairLock
    8  swift: firstRange(of:)
    2  swift: TimeZone.gmt
   31  swift: import Observation
   26  swift: @Observable
  101  swift: @ObservationIgnored
    3  swift: withObservationTracking
    3  swift: SF Symbols
       manifest: Packages/HostRuntime (HostRuntime: BigSurCompat, HostRuntimeTests: BigSurCompat)
       manifest: Packages/DeviceRuntime (DeviceRuntime: BigSurCompat)
       manifest: Packages/DeviceServices (HostServiceClient: BigSurCompat, HostServiceWire: BigSurCompat, HostServiceWireTests: BigSurCompat)
       manifest: Packages/FirmwareKit (FirmwareKit: BigSurCompat, FirmwareKitTests: BigSurCompat)
       manifest: Packages/LightTouchCore (LightTouchCore: BigSurCompat+ObservationCompat, LightTouchCoreTests: BigSurCompat+ObservationCompat)
       manifest: tests/offline (AppViews: BigSurCompat+ObservationCompat, Display: BigSurCompat, Engine: BigSurCompat, Model: BigSurCompat, OfflineTests: BigSurCompat, Sidebar: BigSurCompat)
== 4. patches
Done: /Users/runner/work/LightTouchMac/LightTouchMac/src is the Big Sur tree on bigsur-applied-660c4a55.

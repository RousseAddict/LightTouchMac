Applying the Big Sur port to /Users/runner/work/LightTouchMac/LightTouchMac/src (660c4a5) on branch bigsur-applied-660c4a5
== 1. add
  LightTouchDevice/UpstreamRouter.swift
  LightTouchMac/BigSur/AppKitCompat.swift
  LightTouchMac/BigSur/MapKitCompat.swift
  LightTouchMac/BigSur/SwiftUICompat.swift
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
  Packages/BigSurCompat/Sources/BigSurCompat/CompatFormat.swift
  Packages/BigSurCompat/Sources/BigSurCompat/CompatLocale.swift
  Packages/BigSurCompat/Sources/BigSurCompat/CompatRegex.swift
  Packages/BigSurCompat/Sources/BigSurCompat/CompatUnfairLock.swift
  Packages/BigSurCompat/Sources/BigSurCompat/FoundationCompat.swift
  Packages/BigSurCompat/Sources/BigSurCompat/URLSessionCompat.swift
  Packages/BigSurCompat/Sources/compat-checks/Checks.swift
  Packages/DeviceServices/Sources/HostServiceWire/BigSurExports.swift
  Packages/HostRuntime/Sources/HostRuntime/BigSurExports.swift
  Packages/LightTouchCore/Sources/LightTouchCore/BigSur/AVAssetCompat.swift
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
  LightTouchMac/Features/CanvasCapture.swift
  LightTouchMac/UI/InlineLiveTextView.swift
== 3. codemod
    1  xcconfig: macOS 11
    4  project: macOS 11
    1  project: objectVersion 77
    1  project: swift-subprocess as a local package
    1  project: Sparkle as a local package
   14  native: compiler and linker minimums
    1  native: iBoot32Patcher's Mach-O check
    1  native: the vendor build's Mach-O check
    1  native: check-macho's default
    3  native: the recorded deployment target
    4  swiftui: @Bindable
    3  swiftui: .textSelection(.enabled)
    5  swiftui: .monospacedDigit()
    7  swiftui: .task
    4  swiftui: .formStyle(.grouped)
    3  swiftui: .scrollDisabled
    2  swiftui: .onGeometryChange
    4  swiftui: .onChange(of:)
    9  swiftui: LabeledContent
    2  swiftui: NavigationSplitView
    1  swiftui: .navigationSplitViewColumnWidth
    9  swiftui: Section(title)
    1  swiftui: .fileDialogDefaultDirectory
   35  swiftui: .foregroundStyle
    2  swiftui: Grid
    1  swiftui: GridRow
    1  swiftui: .gridColumnAlignment
    2  swiftui: .background(.quaternary, in:)
    1  swiftui: .selectionDisabled
    1  swiftui: .contextMenu(forSelectionType:)
   21  swiftui: views observe ObservationCompat models
    1  app: urlsForApplications(toOpen:)
    5  app: .inspectorTrackingSeparator
    2  app: .toggleInspector
    1  app: sectionHeader(title:)
    2  app: loadViewIfNeeded()
    1  app: NSColor.systemFill
   33  swift: Duration
   49  swift: ContinuousClock
    6  swift: SuspendingClock
  180  swift: Task.sleep(for:)
   13  swift: OSAllocatedUnfairLock
    9  swift: .formatted(.byteCount(style: .file))
    1  swift: .formatted(date:time:)
    8  swift: firstRange(of:)
    2  swift: TimeZone.gmt
    3  swift: URLSession data(for:)
    1  swift: URLSession download(for:delegate:)
   16  media: load(.property)
    4  media: loadTracks(withMediaType:)
   31  swift: import Observation
   26  swift: @Observable
  101  swift: @ObservationIgnored
    3  swift: withObservationTracking
    7  swift: SF Symbols
    7  icon: Xcode 27 keys dropped for Xcode 26's actool
   15  tests/offline: the app's compat files linked into the targets that compile app files
       manifest: Packages/HostRuntime (HostRuntime: BigSurCompat, HostRuntimeTests: BigSurCompat)
       manifest: Packages/DeviceRuntime (DeviceRuntime: BigSurCompat)
       manifest: Packages/DeviceServices (HostServiceClient: BigSurCompat, HostServiceWire: BigSurCompat, HostServiceWireTests: BigSurCompat)
       manifest: Packages/FirmwareKit (FirmwareKit: BigSurCompat, FirmwareKitTests: BigSurCompat)
       manifest: Packages/LightTouchCore (LightTouchCore: BigSurCompat+ObservationCompat, LightTouchCoreTests: BigSurCompat+ObservationCompat)
       manifest: tests/offline (AppViews: BigSurCompat+ObservationCompat, Display: BigSurCompat+ObservationCompat, Engine: BigSurCompat, Menus: BigSurCompat+ObservationCompat, Model: BigSurCompat+ObservationCompat, OfflineTests: BigSurCompat, Sidebar: BigSurCompat+ObservationCompat)
== 4. patches
  01-xcode26-compiler.patch
  02-helper-power.patch
  03-helper-proxy.patch
  04-displaylink.patch
  05-regex.patch
  06-locale.patch
  07-formatting.patch
  08-toolbar-inspector.patch
  09-menus.patch
  10-phone-remote-openssl.patch
  11-device-model.patch
  12-add-device-sheet.patch
  13-capture-banner.patch
  14-carrier-panel.patch
  15-catalog-details.patch
  16-tweaks-commit-field.patch
  17-vendor-host-only.patch
Done: /Users/runner/work/LightTouchMac/LightTouchMac/src is the Big Sur tree on bigsur-applied-660c4a5.

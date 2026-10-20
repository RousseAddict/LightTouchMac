## lowered: ** BUILD FAILED ** (exit 65, 75s)

Settings: `MACOSX_DEPLOYMENT_TARGET=11.0`. 

75 distinct errors.

| Module | Errors |
|---|---|
| dependency swift-subprocess | 40 |
| HostRuntime | 9 |
| LightTouchServices | 8 |
| app | 4 |
| LightTouchCore | 4 |
| LightTouchDevice | 2 |
| HostServiceWire | 2 |
| FirmwareKit | 2 |
| FirmwareKitCLI | 2 |
| DeviceRuntime | 1 |
| HostServiceClient | 1 |

### Unavailable at the deployment target

| macOS | API | Sites |
|---|---|---|
| 13.0 | `ContinuousClock` | LightTouchServices/Engine/DeviceServices+Engine.swift:18 |
| 13.0 | `Duration` | swift-subprocess/Sources/Subprocess/Teardown.swift:145, swift-subprocess/Sources/Subprocess/Teardown.swift:34, swift-subprocess/Sources/Subprocess/Teardown.swift:36, swift-subprocess/Sources/Subprocess/Teardown.swift:56 (+1) |
| 13.0 | `OSAllocatedUnfairLock` | Packages/HostRuntime/Sources/HostRuntime/PipeOutput.swift:14, Packages/HostRuntime/Sources/HostRuntime/Storage/HeldLease.swift:8, Packages/HostRuntime/Sources/HostRuntime/Storage/StorageLease.swift:13, Packages/HostRuntime/Sources/HostRuntime/Storage/StorageLease.swift:35 (+8) |
| 13.0 | `duration(to:)` | LightTouchServices/Engine/DeviceServices+Engine.swift:32 |
| 13.0 | `init(initialState:)` | Packages/HostRuntime/Sources/HostRuntime/PipeOutput.swift:14, Packages/HostRuntime/Sources/HostRuntime/Storage/HeldLease.swift:8, Packages/HostRuntime/Sources/HostRuntime/Storage/StorageLease.swift:35, swift-subprocess/Sources/Subprocess/IO/AsyncIO+KQueue.swift:420 (+4) |
| 13.0 | `now` | LightTouchServices/Engine/DeviceServices+Engine.swift:18, LightTouchServices/Engine/DeviceServices+Engine.swift:32 |
| 13.0 | `seconds` | LightTouchServices/Engine/DeviceExecution.swift:40, LightTouchServices/Engine/InstallationProxy.swift:337, Packages/DeviceServices/Sources/HostServiceWire/SoftDeadline.swift:17 |
| 13.0 | `sleep(for:tolerance:clock:)` | LightTouchServices/Engine/DeviceExecution.swift:40, LightTouchServices/Engine/InstallationProxy.swift:337, Packages/DeviceServices/Sources/HostServiceWire/SoftDeadline.swift:17, swift-subprocess/Sources/Subprocess/Teardown.swift:215 (+1) |
| 12.0 | `appending` | swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Unix.swift:445 |
| 12.0 | `duplicate(as:retryOnInterrupt:)` | swift-subprocess/Sources/Subprocess/Configuration.swift:1084 |
| 12.0 | `isAbsolute` | swift-subprocess/Sources/Subprocess/Configuration.swift:427, swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Unix.swift:382 |
| 12.3 | `pipe()` | swift-subprocess/Sources/Subprocess/Configuration.swift:1294, swift-subprocess/Sources/Subprocess/IO/AsyncIO+KQueue.swift:84, swift-subprocess/Sources/Subprocess/Platforms/Subprocess+BSD.swift:347, swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Unix.swift:535 |
| 12.0 | `string` | swift-subprocess/Sources/Subprocess/Configuration.swift:203, swift-subprocess/Sources/Subprocess/Configuration.swift:216, swift-subprocess/Sources/Subprocess/Configuration.swift:438, swift-subprocess/Sources/Subprocess/Configuration.swift:448 (+6) |
| 12.0 | `withPlatformString` | swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Darwin.swift:393 |

### Other errors (first 60)

- `LightTouchDevice/main.swift:1: Unable to find module dependency: 'DeviceRuntime'`
- `LightTouchDevice/main.swift:3: Unable to find module dependency: 'HostRuntime'`
- `LightTouchMac/App/AppDelegate.swift:2: Unable to find module dependency: 'DeviceRuntime'`
- `LightTouchMac/App/AppDelegate.swift:3: Unable to find module dependency: 'HostRuntime'`
- `LightTouchMac/App/main.swift:2: Unable to find module dependency: 'LightTouchCore'`
- `LightTouchMac/Device/EmulatorController.swift:5: Unable to find module dependency: 'HostServiceClient'`
- `Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLink.swift:2: Unable to find module dependency: 'HostRuntime'`
- `Packages/DeviceServices/Sources/HostServiceClient/HostServiceWorkers.swift:3: Unable to find module dependency: 'Subprocess'`
- `Packages/FirmwareKit/Sources/FirmwareKit/DiskImage/DiskImage.swift:19: Unable to find module dependency: 'Subprocess'`
- `Packages/FirmwareKit/Sources/FirmwareKit/DiskImage/FirmwareDiagnostics.swift:3: Unable to find module dependency: 'HostRuntime'`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:17: Unable to find module dependency: 'FirmwareKit'`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:20: Unable to find module dependency: 'HostRuntime'`
- `Packages/HostRuntime/Sources/HostRuntime/BootRecipe.swift:284: the compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions`
- `Packages/HostRuntime/Sources/HostRuntime/BootRecipe.swift:341: the compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions`
- `Packages/LightTouchCore/Sources/LightTouchCore/Device/Board+App.swift:6: Unable to find module dependency: 'HostRuntime'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Device/DeviceProcess.swift:2: Unable to find module dependency: 'DeviceRuntime'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Features/AppInstallPipeline.swift:11: Unable to find module dependency: 'Subprocess'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Features/AppInstallPipeline.swift:9: Unable to find module dependency: 'HostServiceClient'`

### Failed build commands (first 30)

- EmitSwiftModule normal arm64 (in target 'HostRuntime' from project 'HostRuntime')
- SwiftEmitModule normal arm64 Emitting\ module\ for\ HostRuntime (in target 'HostRuntime' from project 'HostRuntime')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/HostRuntime.swiftmodule/arm64-apple-macos.swiftmodule /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/HostRuntime.build/Debug/HostRuntime.build/Objects-normal/arm64/HostRuntime.swiftmodule (in target 'HostRuntime' from project 'HostRuntime')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/HostRuntime.swiftmodule/arm64-apple-macos.swiftdoc /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/HostRuntime.build/Debug/HostRuntime.build/Objects-normal/arm64/HostRuntime.swiftdoc (in target 'HostRuntime' from project 'HostRuntime')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/HostRuntime.swiftmodule/arm64-apple-macos.abi.json /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/HostRuntime.build/Debug/HostRuntime.build/Objects-normal/arm64/HostRuntime.abi.json (in target 'HostRuntime' from project 'HostRuntime')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/HostRuntime.swiftmodule/Project/arm64-apple-macos.swiftsourceinfo /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/HostRuntime.build/Debug/HostRuntime.build/Objects-normal/arm64/HostRuntime.swiftsourceinfo (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal arm64 Compiling\ HostServiceTypes.swift,\ SoftDeadline.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceServices/Sources/HostServiceWire/HostServiceTypes.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceServices/Sources/HostServiceWire/SoftDeadline.swift (in target 'HostServiceWire' from project 'DeviceServices')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceServices/Sources/HostServiceWire/SoftDeadline.swift (in target 'HostServiceWire' from project 'DeviceServices')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/HeldLease.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StorageLease.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal arm64 Compiling\ HeldLease.swift,\ PropertyListFile.swift,\ StoppedRecordOwner.swift,\ StorageBootProof.swift,\ StorageLease.swift,\ StoragePathAuthority.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/HeldLease.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/PropertyListFile.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StoppedRecordOwner.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StorageBootProof.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StorageLease.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StoragePathAuthority.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/PipeOutput.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal arm64 Compiling\ GuestPack.swift,\ HelperLaunch.swift,\ IPhoneIdentity.swift,\ PipeOutput.swift,\ PreparedDeviceBoot.swift,\ DeviceRecord.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/GuestPack.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/HelperLaunch.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/IPhoneIdentity.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/PipeOutput.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/PreparedDeviceBoot.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/DeviceRecord.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/BootRecipe.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal arm64 Compiling\ Board.swift,\ BootConfig.swift,\ BootRecipe.swift,\ CarrierSettings.swift,\ DebugPort.swift,\ DeviceInfo.swift,\ DeviceLock.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Board.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/BootConfig.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/BootRecipe.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/CarrierSettings.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/DebugPort.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/DeviceInfo.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/DeviceLock.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftEmitModule normal arm64 Emitting\ module\ for\ Subprocess (in target 'Subprocess' from project 'swift-subprocess')
- EmitSwiftModule normal arm64 (in target 'Subprocess' from project 'swift-subprocess')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/Subprocess.swiftmodule/arm64-apple-macos.swiftmodule /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/swift-subprocess.build/Debug/Subprocess.build/Objects-normal/arm64/Subprocess.swiftmodule (in target 'Subprocess' from project 'swift-subprocess')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/Subprocess.swiftmodule/arm64-apple-macos.swiftdoc /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/swift-subprocess.build/Debug/Subprocess.build/Objects-normal/arm64/Subprocess.swiftdoc (in target 'Subprocess' from project 'swift-subprocess')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/Subprocess.swiftmodule/arm64-apple-macos.abi.json /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/swift-subprocess.build/Debug/Subprocess.build/Objects-normal/arm64/Subprocess.abi.json (in target 'Subprocess' from project 'swift-subprocess')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/Subprocess.swiftmodule/Project/arm64-apple-macos.swiftsourceinfo /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/swift-subprocess.build/Debug/Subprocess.build/Objects-normal/arm64/Subprocess.swiftsourceinfo (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal arm64 Compiling\ AsyncIO+Windows.swift,\ Input.swift,\ Output.swift,\ Subprocess+BSD.swift,\ Subprocess+Darwin.swift,\ Subprocess+Linux.swift,\ Subprocess+Unix.swift,\ Subprocess+Windows.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/AsyncIO+Windows.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/Input.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/Output.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+BSD.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Darwin.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Linux.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Unix.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Windows.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal arm64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+BSD.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal arm64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Darwin.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal arm64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Unix.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal arm64 Compiling\ API.swift,\ Buffer.swift,\ Configuration.swift,\ Error.swift,\ Execution.swift,\ AsyncIO+KQueue.swift,\ AsyncIO+Linux.swift,\ AsyncIO+Unix.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/API.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Buffer.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Configuration.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Error.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Execution.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/AsyncIO+KQueue.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/AsyncIO+Linux.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/AsyncIO+Unix.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal arm64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/API.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal arm64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Buffer.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal arm64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Configuration.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal arm64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Error.swift (in target 'Subprocess' from project 'swift-subprocess')

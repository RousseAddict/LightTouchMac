## lowered: ** BUILD FAILED ** (exit 65, 272s)

Settings: `MACOSX_DEPLOYMENT_TARGET=11.0`. 

89 distinct errors.

| Module | Errors |
|---|---|
| dependency swift-subprocess | 40 |
| app | 8 |
| LightTouchServices | 8 |
| LightTouchCore | 8 |
| HostRuntime | 7 |
| LightTouchDevice | 4 |
| FirmwareKit | 4 |
| FirmwareKitCLI | 4 |
| DeviceRuntime | 2 |
| HostServiceClient | 2 |
| HostServiceWire | 2 |

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

### Errors without a source location (first 30)

- `error: The file “HostRuntime.swiftmodule” couldn’t be opened because there is no such file. (in target 'HostRuntime' from project 'HostRuntime')`
- `error: The file “HostRuntime.swiftdoc” couldn’t be opened because there is no such file. (in target 'HostRuntime' from project 'HostRuntime')`
- `error: The file “HostRuntime.abi.json” couldn’t be opened because there is no such file. (in target 'HostRuntime' from project 'HostRuntime')`
- `error: The file “HostRuntime.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'HostRuntime' from project 'HostRuntime')`
- `error: The file “Subprocess.swiftmodule” couldn’t be opened because there is no such file. (in target 'Subprocess' from project 'swift-subprocess')`
- `error: The file “Subprocess.swiftdoc” couldn’t be opened because there is no such file. (in target 'Subprocess' from project 'swift-subprocess')`
- `error: The file “Subprocess.abi.json” couldn’t be opened because there is no such file. (in target 'Subprocess' from project 'swift-subprocess')`
- `error: The file “Subprocess.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'Subprocess' from project 'swift-subprocess')`
- `error: The file “HostServiceClient.swiftmodule” couldn’t be opened because there is no such file. (in target 'HostServiceClient' from project 'DeviceServices')`
- `error: The file “HostServiceClient.swiftdoc” couldn’t be opened because there is no such file. (in target 'HostServiceClient' from project 'DeviceServices')`
- `error: The file “HostServiceClient.abi.json” couldn’t be opened because there is no such file. (in target 'HostServiceClient' from project 'DeviceServices')`
- `error: The file “HostServiceClient.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'HostServiceClient' from project 'DeviceServices')`
- `error: The file “DeviceRuntime.swiftmodule” couldn’t be opened because there is no such file. (in target 'DeviceRuntime' from project 'DeviceRuntime')`
- `error: The file “DeviceRuntime.swiftdoc” couldn’t be opened because there is no such file. (in target 'DeviceRuntime' from project 'DeviceRuntime')`
- `error: The file “DeviceRuntime.abi.json” couldn’t be opened because there is no such file. (in target 'DeviceRuntime' from project 'DeviceRuntime')`
- `error: The file “DeviceRuntime.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'DeviceRuntime' from project 'DeviceRuntime')`
- `error: The file “LightTouchServices.swiftmodule” couldn’t be opened because there is no such file. (in target 'LightTouchServices' from project 'LightTouchMac')`
- `error: The file “LightTouchServices.swiftdoc” couldn’t be opened because there is no such file. (in target 'LightTouchServices' from project 'LightTouchMac')`
- `error: The file “LightTouchServices.abi.json” couldn’t be opened because there is no such file. (in target 'LightTouchServices' from project 'LightTouchMac')`
- `error: The file “LightTouchServices.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'LightTouchServices' from project 'LightTouchMac')`
- `error: The file “LightTouchDevice.swiftmodule” couldn’t be opened because there is no such file. (in target 'LightTouchDevice' from project 'LightTouchMac')`
- `error: The file “LightTouchDevice.swiftdoc” couldn’t be opened because there is no such file. (in target 'LightTouchDevice' from project 'LightTouchMac')`
- `error: The file “LightTouchDevice.abi.json” couldn’t be opened because there is no such file. (in target 'LightTouchDevice' from project 'LightTouchMac')`
- `error: The file “LightTouchDevice.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'LightTouchDevice' from project 'LightTouchMac')`
- `error: The file “FirmwareKit.swiftmodule” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “FirmwareKit.swiftdoc” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “FirmwareKit.abi.json” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “FirmwareKit.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “LightTouchCore.swiftmodule” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`
- `error: The file “LightTouchCore.swiftdoc” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`

### Other errors (first 60)

- `LightTouchDevice/main.swift:1: Unable to resolve module dependency: 'DeviceRuntime'`
- `LightTouchDevice/main.swift:1: unable to resolve module dependency: 'DeviceRuntime'`
- `LightTouchDevice/main.swift:3: Unable to resolve module dependency: 'HostRuntime'`
- `LightTouchDevice/main.swift:3: unable to resolve module dependency: 'HostRuntime'`
- `LightTouchMac/App/AppDelegate.swift:2: Unable to resolve module dependency: 'DeviceRuntime'`
- `LightTouchMac/App/AppDelegate.swift:2: unable to resolve module dependency: 'DeviceRuntime'`
- `LightTouchMac/App/AppDelegate.swift:3: Unable to resolve module dependency: 'HostRuntime'`
- `LightTouchMac/App/AppDelegate.swift:3: unable to resolve module dependency: 'HostRuntime'`
- `LightTouchMac/App/main.swift:2: Unable to resolve module dependency: 'LightTouchCore'`
- `LightTouchMac/App/main.swift:2: unable to resolve module dependency: 'LightTouchCore'`
- `LightTouchMac/Device/EmulatorController.swift:5: Unable to resolve module dependency: 'HostServiceClient'`
- `LightTouchMac/Device/EmulatorController.swift:5: unable to resolve module dependency: 'HostServiceClient'`
- `Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLink.swift:2: Unable to resolve module dependency: 'HostRuntime'`
- `Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLink.swift:2: unable to resolve module dependency: 'HostRuntime'`
- `Packages/DeviceServices/Sources/HostServiceClient/HostServiceWorkers.swift:3: Unable to resolve module dependency: 'Subprocess'`
- `Packages/DeviceServices/Sources/HostServiceClient/HostServiceWorkers.swift:3: unable to resolve module dependency: 'Subprocess'`
- `Packages/FirmwareKit/Sources/FirmwareKit/DiskImage/DiskImage.swift:19: Unable to resolve module dependency: 'Subprocess'`
- `Packages/FirmwareKit/Sources/FirmwareKit/DiskImage/DiskImage.swift:19: unable to resolve module dependency: 'Subprocess'`
- `Packages/FirmwareKit/Sources/FirmwareKit/DiskImage/FirmwareDiagnostics.swift:3: Unable to resolve module dependency: 'HostRuntime'`
- `Packages/FirmwareKit/Sources/FirmwareKit/DiskImage/FirmwareDiagnostics.swift:3: unable to resolve module dependency: 'HostRuntime'`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:17: Unable to resolve module dependency: 'FirmwareKit'`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:17: unable to resolve module dependency: 'FirmwareKit'`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:20: Unable to resolve module dependency: 'HostRuntime'`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:20: unable to resolve module dependency: 'HostRuntime'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Device/Board+App.swift:6: Unable to resolve module dependency: 'HostRuntime'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Device/Board+App.swift:6: unable to resolve module dependency: 'HostRuntime'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Device/DeviceProcess.swift:2: Unable to resolve module dependency: 'DeviceRuntime'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Device/DeviceProcess.swift:2: unable to resolve module dependency: 'DeviceRuntime'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Features/AppInstallPipeline.swift:11: Unable to resolve module dependency: 'Subprocess'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Features/AppInstallPipeline.swift:11: unable to resolve module dependency: 'Subprocess'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Features/AppInstallPipeline.swift:9: Unable to resolve module dependency: 'HostServiceClient'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Features/AppInstallPipeline.swift:9: unable to resolve module dependency: 'HostServiceClient'`

### Failed build commands (first 30)

- SwiftEmitModule normal x86_64 Emitting\ module\ for\ HostRuntime (in target 'HostRuntime' from project 'HostRuntime')
- EmitSwiftModule normal x86_64 (in target 'HostRuntime' from project 'HostRuntime')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/HostRuntime.swiftmodule/x86_64-apple-macos.swiftmodule /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/HostRuntime.build/Debug/HostRuntime.build/Objects-normal/x86_64/HostRuntime.swiftmodule (in target 'HostRuntime' from project 'HostRuntime')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/HostRuntime.swiftmodule/x86_64-apple-macos.swiftdoc /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/HostRuntime.build/Debug/HostRuntime.build/Objects-normal/x86_64/HostRuntime.swiftdoc (in target 'HostRuntime' from project 'HostRuntime')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/HostRuntime.swiftmodule/x86_64-apple-macos.abi.json /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/HostRuntime.build/Debug/HostRuntime.build/Objects-normal/x86_64/HostRuntime.abi.json (in target 'HostRuntime' from project 'HostRuntime')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/HostRuntime.swiftmodule/Project/x86_64-apple-macos.swiftsourceinfo /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/HostRuntime.build/Debug/HostRuntime.build/Objects-normal/x86_64/HostRuntime.swiftsourceinfo (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal x86_64 Compiling\ SoftDeadline.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceServices/Sources/HostServiceWire/SoftDeadline.swift (in target 'HostServiceWire' from project 'DeviceServices')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceServices/Sources/HostServiceWire/SoftDeadline.swift (in target 'HostServiceWire' from project 'DeviceServices')
- SwiftCompile normal x86_64 Compiling\ StoppedRecordOwner.swift,\ StorageBootProof.swift,\ StorageLease.swift,\ StoragePathAuthority.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StoppedRecordOwner.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StorageBootProof.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StorageLease.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StoragePathAuthority.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/StorageLease.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal x86_64 Compiling\ PipeOutput.swift,\ PreparedDeviceBoot.swift,\ DeviceRecord.swift,\ HeldLease.swift,\ PropertyListFile.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/PipeOutput.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/PreparedDeviceBoot.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/DeviceRecord.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/HeldLease.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/PropertyListFile.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/PipeOutput.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/Storage/HeldLease.swift (in target 'HostRuntime' from project 'HostRuntime')
- EmitSwiftModule normal x86_64 (in target 'Subprocess' from project 'swift-subprocess')
- SwiftEmitModule normal x86_64 Emitting\ module\ for\ Subprocess (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+BSD.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 Compiling\ AsyncIO+Linux.swift,\ AsyncIO+Unix.swift,\ AsyncIO+Windows.swift,\ Input.swift,\ Output.swift,\ Subprocess+BSD.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/AsyncIO+Linux.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/AsyncIO+Unix.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/AsyncIO+Windows.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/Input.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/Output.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+BSD.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 Compiling\ Subprocess+Darwin.swift,\ Subprocess+Linux.swift,\ Subprocess+Unix.swift,\ Subprocess+Windows.swift,\ Result.swift,\ Span+Subprocess.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Darwin.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Linux.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Unix.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Windows.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Result.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Span+Subprocess.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Darwin.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Platforms/Subprocess+Unix.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/API.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Buffer.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Configuration.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Error.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Execution.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/AsyncIO+KQueue.swift (in target 'Subprocess' from project 'swift-subprocess')
- SwiftCompile normal x86_64 Compiling\ API.swift,\ Buffer.swift,\ Configuration.swift,\ Error.swift,\ Execution.swift,\ AsyncIO+KQueue.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/API.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Buffer.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Configuration.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Error.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/Execution.swift /Users/runner/work/_temp/dd-lowered/SourcePackages/checkouts/swift-subprocess/Sources/Subprocess/IO/AsyncIO+KQueue.swift (in target 'Subprocess' from project 'swift-subprocess')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/Subprocess.swiftmodule/x86_64-apple-macos.swiftmodule /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/swift-subprocess.build/Debug/Subprocess.build/Objects-normal/x86_64/Subprocess.swiftmodule (in target 'Subprocess' from project 'swift-subprocess')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/Subprocess.swiftmodule/x86_64-apple-macos.swiftdoc /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/swift-subprocess.build/Debug/Subprocess.build/Objects-normal/x86_64/Subprocess.swiftdoc (in target 'Subprocess' from project 'swift-subprocess')
- Copy /Users/runner/work/_temp/dd-lowered/Build/Products/Debug/Subprocess.swiftmodule/x86_64-apple-macos.abi.json /Users/runner/work/_temp/dd-lowered/Build/Intermediates.noindex/swift-subprocess.build/Debug/Subprocess.build/Objects-normal/x86_64/Subprocess.abi.json (in target 'Subprocess' from project 'swift-subprocess')

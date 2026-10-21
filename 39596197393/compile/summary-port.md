## port: ** BUILD FAILED ** (exit 65, 131s)

Settings: `none`. 

16 distinct errors.

| Module | Errors |
|---|---|
| app | 6 |
| FirmwareKit | 4 |
| LightTouchDevice | 2 |
| FirmwareKitCLI | 2 |
| HostRuntime | 1 |
| LightTouchCore | 1 |

### Unavailable at the deployment target

| macOS | API | Sites |
|---|---|---|
| 14.0 | `ProxyConfiguration` | LightTouchDevice/WebProxy.swift:115 |
| 14.0 | `proxyConfigurations` | LightTouchDevice/WebProxy.swift:117 |
| 13 | `region` | Packages/HostRuntime/Sources/HostRuntime/PreparedDeviceBoot.swift:136 |
| 12 | `now` | Packages/LightTouchCore/Sources/LightTouchCore/Features/ClipboardSync.swift:72 |

### Errors without a source location (first 30)

- `error: no complete vendor directory for the current pins (VENDOR_DIR /Users/runner/work/_temp/vendor-stub is not 436db51bc410; drop the override or point it there): run scripts/vendor (about 15 minutes)`
- `error: The file “FirmwareKit.swiftmodule” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “FirmwareKit.swiftdoc” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “FirmwareKit.abi.json” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “FirmwareKit.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `switch object.statusOfValue(forKey: key, error: &error) {`
- `error: The file “LightTouchCore.swiftmodule” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`
- `error: The file “LightTouchCore.swiftdoc” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`
- `error: The file “LightTouchCore.abi.json” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`
- `error: The file “LightTouchCore.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`
- `Internal Error: DecodingError.dataCorrupted: Data was corrupted. Debug description: Corrupted JSON. Underlying error: unexpected end of file`
- `error: The file “FirmwareKitCLI.swiftmodule” couldn’t be opened because there is no such file. (in target 'firmwarekit' from project 'LightTouchMac')`
- `error: The file “FirmwareKitCLI.swiftdoc” couldn’t be opened because there is no such file. (in target 'firmwarekit' from project 'LightTouchMac')`
- `error: The file “FirmwareKitCLI.abi.json” couldn’t be opened because there is no such file. (in target 'firmwarekit' from project 'LightTouchMac')`
- `error: The file “FirmwareKitCLI.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'firmwarekit' from project 'LightTouchMac')`
- `error: The file “Light_Touch.swiftmodule” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “Light_Touch.swiftdoc” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “Light_Touch.abi.json” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “Light_Touch.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “firmwarekit” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “LightTouchDevice” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`

### Other errors (first 60)

- `LightTouchMac/App/main.swift:2: Unable to resolve module dependency: 'LightTouchCore'`
- `LightTouchMac/App/main.swift:2: unable to resolve module dependency: 'LightTouchCore'`
- `LightTouchMac/UI/DisplayView.swift:186: Source control conflict marker in source file`
- `LightTouchMac/UI/DisplayView.swift:186: source control conflict marker in source file`
- `LightTouchMac/UI/DisplayView.swift:373: Source control conflict marker in source file`
- `LightTouchMac/UI/DisplayView.swift:373: source control conflict marker in source file`
- `Packages/FirmwareKit/Sources/FirmwareKit/N45/N45Recipe.swift:257: Source control conflict marker in source file`
- `Packages/FirmwareKit/Sources/FirmwareKit/N45/N45Recipe.swift:257: source control conflict marker in source file`
- `Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/SystemEdits.swift:647: Source control conflict marker in source file`
- `Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/SystemEdits.swift:647: source control conflict marker in source file`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:17: Unable to resolve module dependency: 'FirmwareKit'`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:17: unable to resolve module dependency: 'FirmwareKit'`

### Failed build commands (first 30)

- SwiftCompile normal arm64 Compiling\ GuestPack.swift,\ HelperLaunch.swift,\ IPhoneIdentity.swift,\ MachineOptions.swift,\ NetworkPolicy.swift,\ PipeOutput.swift,\ PreparedDeviceBoot.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/GuestPack.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/HelperLaunch.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/IPhoneIdentity.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/MachineOptions.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/NetworkPolicy.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/PipeOutput.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/PreparedDeviceBoot.swift (in target 'HostRuntime' from project 'HostRuntime')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/HostRuntime/Sources/HostRuntime/PreparedDeviceBoot.swift (in target 'HostRuntime' from project 'HostRuntime')
- PhaseScriptExecution Vendor\ Directory /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/LightTouchServices.build/Script-A1D0C0DE3200000000000000C.sh (in target 'LightTouchServices' from project 'LightTouchMac')
- SwiftDriver FirmwareKit normal arm64 com.apple.xcode.tools.swift.compiler (in target 'FirmwareKit' from project 'FirmwareKit')
- EmitSwiftModule normal arm64 (in target 'LightTouchCore' from project 'LightTouchCore')
- SwiftEmitModule normal arm64 Emitting\ module\ for\ LightTouchCore (in target 'LightTouchCore' from project 'LightTouchCore')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/FirmwareKit.swiftmodule/arm64-apple-macos.swiftmodule /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/FirmwareKit.build/Debug/FirmwareKit.build/Objects-normal/arm64/FirmwareKit.swiftmodule (in target 'FirmwareKit' from project 'FirmwareKit')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/FirmwareKit.swiftmodule/arm64-apple-macos.swiftdoc /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/FirmwareKit.build/Debug/FirmwareKit.build/Objects-normal/arm64/FirmwareKit.swiftdoc (in target 'FirmwareKit' from project 'FirmwareKit')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/FirmwareKit.swiftmodule/arm64-apple-macos.abi.json /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/FirmwareKit.build/Debug/FirmwareKit.build/Objects-normal/arm64/FirmwareKit.abi.json (in target 'FirmwareKit' from project 'FirmwareKit')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/FirmwareKit.swiftmodule/Project/arm64-apple-macos.swiftsourceinfo /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/FirmwareKit.build/Debug/FirmwareKit.build/Objects-normal/arm64/FirmwareKit.swiftsourceinfo (in target 'FirmwareKit' from project 'FirmwareKit')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/LightTouchCore.swiftmodule/arm64-apple-macos.swiftmodule /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchCore.build/Debug/LightTouchCore.build/Objects-normal/arm64/LightTouchCore.swiftmodule (in target 'LightTouchCore' from project 'LightTouchCore')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/LightTouchCore.swiftmodule/arm64-apple-macos.swiftdoc /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchCore.build/Debug/LightTouchCore.build/Objects-normal/arm64/LightTouchCore.swiftdoc (in target 'LightTouchCore' from project 'LightTouchCore')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/LightTouchCore.swiftmodule/arm64-apple-macos.abi.json /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchCore.build/Debug/LightTouchCore.build/Objects-normal/arm64/LightTouchCore.abi.json (in target 'LightTouchCore' from project 'LightTouchCore')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/LightTouchCore.swiftmodule/Project/arm64-apple-macos.swiftsourceinfo /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchCore.build/Debug/LightTouchCore.build/Objects-normal/arm64/LightTouchCore.swiftsourceinfo (in target 'LightTouchCore' from project 'LightTouchCore')
- SwiftCompile normal arm64 Compiling\ WebProxyConfiguration.swift,\ Accessibility.swift,\ AppInstallPipeline.swift,\ AppInstaller.swift,\ BugReportInfo.swift,\ CaptureFileMonitor.swift,\ CaptureNotificationContent.swift,\ CapturePreferences.swift,\ CatalogClient.swift,\ CatalogCopy.swift,\ CatalogFilter.swift,\ ClipboardSync.swift,\ DiagnosticsExport.swift,\ DisplayRefresh.swift,\ InstallationQueue.swift,\ MediaIdentity.swift,\ MediaImport.swift,\ MediaPhoto.swift,\ MediaSong.swift,\ MediaSupport.swift,\ MediaVideo.swift,\ PreparedMedia.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Device/WebProxyConfiguration.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/Accessibility.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/AppInstallPipeline.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/AppInstaller.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/BugReportInfo.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/CaptureFileMonitor.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/CaptureNotificationContent.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/CapturePreferences.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/CatalogClient.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/CatalogCopy.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/CatalogFilter.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/ClipboardSync.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/DiagnosticsExport.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/DisplayRefresh.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/InstallationQueue.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/MediaIdentity.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/MediaImport.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/MediaPhoto.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/MediaSong.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/MediaSupport.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/MediaVideo.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/PreparedMedia.swift (in target 'LightTouchCore' from project 'LightTouchCore')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/LightTouchCore/Sources/LightTouchCore/Features/ClipboardSync.swift (in target 'LightTouchCore' from project 'LightTouchCore')
- SwiftCompile normal arm64 Compiling\ UpstreamRouter.swift,\ WebProxy.swift,\ WebProxyAdapters.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchDevice/UpstreamRouter.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchDevice/WebProxy.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchDevice/WebProxyAdapters.swift (in target 'LightTouchDevice' from project 'LightTouchMac')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchDevice/WebProxy.swift (in target 'LightTouchDevice' from project 'LightTouchMac')
- SwiftDriver firmwarekit normal arm64 com.apple.xcode.tools.swift.compiler (in target 'firmwarekit' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/FirmwareKitCLI.swiftmodule/arm64-apple-macos.swiftmodule /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/firmwarekit.build/Objects-normal/arm64/FirmwareKitCLI.swiftmodule (in target 'firmwarekit' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/FirmwareKitCLI.swiftmodule/arm64-apple-macos.swiftdoc /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/firmwarekit.build/Objects-normal/arm64/FirmwareKitCLI.swiftdoc (in target 'firmwarekit' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/FirmwareKitCLI.swiftmodule/arm64-apple-macos.abi.json /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/firmwarekit.build/Objects-normal/arm64/FirmwareKitCLI.abi.json (in target 'firmwarekit' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/FirmwareKitCLI.swiftmodule/Project/arm64-apple-macos.swiftsourceinfo /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/firmwarekit.build/Objects-normal/arm64/FirmwareKitCLI.swiftsourceinfo (in target 'firmwarekit' from project 'LightTouchMac')
- SwiftDriver Light\ Touch normal arm64 com.apple.xcode.tools.swift.compiler (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/Light_Touch.swiftmodule/arm64-apple-macos.swiftmodule /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/Light\ Touch.build/Objects-normal/arm64/Light_Touch.swiftmodule (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/Light_Touch.swiftmodule/arm64-apple-macos.swiftdoc /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/Light\ Touch.build/Objects-normal/arm64/Light_Touch.swiftdoc (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/Light_Touch.swiftmodule/arm64-apple-macos.abi.json /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/Light\ Touch.build/Objects-normal/arm64/Light_Touch.abi.json (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/Light_Touch.swiftmodule/Project/arm64-apple-macos.swiftsourceinfo /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/Light\ Touch.build/Objects-normal/arm64/Light_Touch.swiftsourceinfo (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/Light\ Touch.app/Contents/MacOS/firmwarekit /Users/runner/work/_temp/dd-port/Build/Products/Debug/firmwarekit (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/Light\ Touch.app/Contents/MacOS/LightTouchDevice /Users/runner/work/_temp/dd-port/Build/Products/Debug/LightTouchDevice (in target 'Light Touch' from project 'LightTouchMac')

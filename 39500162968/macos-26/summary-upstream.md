## upstream: ** BUILD FAILED ** (exit 65, 172s)

Settings: `none`. 

2 distinct errors.

| Module | Errors |
|---|---|
| DeviceRuntime | 1 |
| FirmwareKit | 1 |

### Errors without a source location (first 30)

- `error: Exception while running actool: *** -[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[0]`
- `error: The file “firmwarekit” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “LightTouchDevice” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`

### Other errors (first 60)

- `Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLink.swift:268: closure captures 'channel' before it is declared`
- `Packages/FirmwareKit/Sources/FirmwareKit/K48/K48Recipe.swift:205: ambiguous use of 'init'`

### Failed build commands (first 30)

- SwiftCompile normal arm64 Compiling\ DeviceLink.swift,\ DeviceLinkProtocol.swift,\ DeviceRendezvous.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLink.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLinkProtocol.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceRendezvous.swift (in target 'DeviceRuntime' from project 'DeviceRuntime')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLink.swift (in target 'DeviceRuntime' from project 'DeviceRuntime')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLinkProtocol.swift (in target 'DeviceRuntime' from project 'DeviceRuntime')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceRendezvous.swift (in target 'DeviceRuntime' from project 'DeviceRuntime')
- SwiftCompile normal arm64 Compiling\ Archive.swift,\ RARSource.swift,\ SourceFetch.swift,\ BuildIdentity.swift,\ Bytes.swift,\ DiskImage.swift,\ FirmwareDiagnostics.swift,\ FirmwareBootAdmission.swift,\ FirmwareKit.swift,\ FitCheck.swift,\ Pieces.swift,\ GLIDispatch.swift,\ GuestPackage.swift,\ HFSPlus.swift,\ IMG2.swift,\ FirmwareDecryptor.swift,\ IMG3.swift,\ Identity.swift,\ K48Recipe.swift,\ K48IBoot.swift,\ K48NAND.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/Archive/Archive.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/Archive/RARSource.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/Archive/SourceFetch.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/BuildIdentity/BuildIdentity.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/Bytes/Bytes.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/DiskImage/DiskImage.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/DiskImage/FirmwareDiagnostics.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/FirmwareBootAdmission.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/FirmwareKit.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/FitCheck/FitCheck.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/FitCheck/Pieces.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/GLIDispatchCheck/GLIDispatch.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/GuestPackage/GuestPackage.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/HFSPlus/HFSPlus.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/IMG2/IMG2.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/IMG3/FirmwareDecryptor.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/IMG3/IMG3.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/Identity/Identity.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48/K48Recipe.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48IBoot/K48IBoot.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48NAND/K48NAND.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal arm64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48/K48Recipe.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- CompileAssetCatalogVariant thinned /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/Light\ Touch.app/Contents/Resources /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchMac/Assets.xcassets /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchMac/LightTouch.icon (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/Light\ Touch.app/Contents/MacOS/firmwarekit /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/firmwarekit (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/Light\ Touch.app/Contents/MacOS/LightTouchDevice /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/LightTouchDevice (in target 'Light Touch' from project 'LightTouchMac')
- Building workspace LightTouchMac with scheme LightTouchMac and configuration Debug

## upstream: ** BUILD FAILED ** (exit 65, 595s)

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

- SwiftCompile normal x86_64 Compiling\ DeviceLink.swift,\ DeviceLinkProtocol.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLink.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLinkProtocol.swift (in target 'DeviceRuntime' from project 'DeviceRuntime')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLink.swift (in target 'DeviceRuntime' from project 'DeviceRuntime')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/DeviceRuntime/Sources/DeviceRuntime/DeviceLinkProtocol.swift (in target 'DeviceRuntime' from project 'DeviceRuntime')
- SwiftCompile normal x86_64 Compiling\ IMG3.swift,\ Identity.swift,\ K48Recipe.swift,\ K48IBoot.swift,\ K48NAND.swift,\ K48NANDCheck.swift,\ K48NANDImage.swift,\ K48NANDMigration.swift,\ DeviceTree.swift,\ KBoot.swift,\ LZSS.swift,\ N45FTL.swift,\ N45Migration.swift,\ N45NAND.swift,\ N45NOR.swift,\ N45Recipe.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/IMG3/IMG3.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/Identity/Identity.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48/K48Recipe.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48IBoot/K48IBoot.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48NAND/K48NAND.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48NAND/K48NANDCheck.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48NAND/K48NANDImage.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48NAND/K48NANDMigration.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/KBoot/DeviceTree.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/KBoot/KBoot.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/LZSS/LZSS.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/N45/N45FTL.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/N45/N45Migration.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/N45/N45NAND.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/N45/N45NOR.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/N45/N45Recipe.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/K48/K48Recipe.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- CompileAssetCatalogVariant thinned /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/Light\ Touch.app/Contents/Resources /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchMac/Assets.xcassets /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchMac/LightTouch.icon (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/Light\ Touch.app/Contents/MacOS/firmwarekit /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/firmwarekit (in target 'Light Touch' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/Light\ Touch.app/Contents/MacOS/LightTouchDevice /Users/runner/work/_temp/dd-upstream/Build/Products/Debug/LightTouchDevice (in target 'Light Touch' from project 'LightTouchMac')
- Building workspace LightTouchMac with scheme LightTouchMac and configuration Debug

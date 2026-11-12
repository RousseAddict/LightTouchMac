## port: ** BUILD FAILED ** (exit 65, 516s)

Settings: `none`. 

7 distinct errors.

| Module | Errors |
|---|---|
| app | 2 |
| FirmwareKitCLI | 2 |
| LightTouchServices | 1 |
| FirmwareKit | 1 |
| LightTouchCore | 1 |

### Errors without a source location (first 30)

- `error: bridging header dependency scanning failure: /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchServices/Lockdown/Lockdown.h:7:10: fatal error: 'libimobiledevice/afc.h' file not found`
- `error: Bridging header dependency scanning failure: /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchServices/Lockdown/Lockdown.h:7:10: fatal error: 'libimobiledevice/afc.h' file not found`
- `error: The file “LightTouchServices.swiftmodule” couldn’t be opened because there is no such file. (in target 'LightTouchServices' from project 'LightTouchMac')`
- `error: The file “LightTouchServices.swiftdoc” couldn’t be opened because there is no such file. (in target 'LightTouchServices' from project 'LightTouchMac')`
- `error: The file “LightTouchServices.abi.json” couldn’t be opened because there is no such file. (in target 'LightTouchServices' from project 'LightTouchMac')`
- `error: The file “LightTouchServices.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'LightTouchServices' from project 'LightTouchMac')`
- `error: The file “FirmwareKit.swiftmodule” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “FirmwareKit.swiftdoc” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “FirmwareKit.abi.json” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “FirmwareKit.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'FirmwareKit' from project 'FirmwareKit')`
- `error: The file “LightTouchCore.swiftmodule” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`
- `error: The file “LightTouchCore.swiftdoc” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`
- `error: The file “LightTouchCore.abi.json” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`
- `error: The file “LightTouchCore.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'LightTouchCore' from project 'LightTouchCore')`
- `error: The file “FirmwareKitCLI.swiftmodule” couldn’t be opened because there is no such file. (in target 'firmwarekit' from project 'LightTouchMac')`
- `error: The file “FirmwareKitCLI.swiftdoc” couldn’t be opened because there is no such file. (in target 'firmwarekit' from project 'LightTouchMac')`
- `error: The file “FirmwareKitCLI.abi.json” couldn’t be opened because there is no such file. (in target 'firmwarekit' from project 'LightTouchMac')`
- `error: The file “FirmwareKitCLI.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'firmwarekit' from project 'LightTouchMac')`
- `error: The file “Light_Touch.swiftmodule” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “Light_Touch.swiftdoc” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “Light_Touch.abi.json” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “Light_Touch.swiftsourceinfo” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “firmwarekit” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The file “LightTouchServices” couldn’t be opened because there is no such file. (in target 'Light Touch' from project 'LightTouchMac')`
- `error: The package product 'BinaryParsing' requires minimum platform version 13.0 for the macOS platform, but this target supports 11.0 (in target 'LightTouchCore' from project 'LightTouchCore')`
- `error: The package product 'BinaryParsing' requires minimum platform version 13.0 for the macOS platform, but this target supports 11.0 (in target 'FirmwareKit' from project 'FirmwareKit')`

### Other errors (first 60)

- `LightTouchMac/App/main.swift:2: Unable to resolve module dependency: 'LightTouchCore'`
- `LightTouchMac/App/main.swift:2: unable to resolve module dependency: 'LightTouchCore'`
- `LightTouchServices/Lockdown/Lockdown.h:7: 'libimobiledevice/afc.h' file not found (in target 'LightTouchServices' from project 'LightTouchMac')`
- `Packages/FirmwareKit/Sources/FirmwareKit/Archive/TarArchive.swift:10: compiling for macOS 11.0, but module 'BinaryParsing' has a minimum deployment target of macOS 13.0: /Users/runner/work/_temp/dd-port/Build/Products/Debug/BinaryParsing.swiftmodule/x86_64-apple-macos.swiftmodule`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:18: Unable to resolve module dependency: 'FirmwareKit'`
- `Packages/FirmwareKit/Sources/FirmwareKitCLI/main.swift:18: unable to resolve module dependency: 'FirmwareKit'`
- `Packages/LightTouchCore/Sources/LightTouchCore/Features/MediaIdentity.swift:1: compiling for macOS 11.0, but module 'BinaryParsing' has a minimum deployment target of macOS 13.0: /Users/runner/work/_temp/dd-port/Build/Products/Debug/BinaryParsing.swiftmodule/x86_64-apple-macos.swiftmodule`

### Failed build commands (first 30)

- SwiftDriver LightTouchServices normal x86_64 com.apple.xcode.tools.swift.compiler (in target 'LightTouchServices' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/LightTouchServices.swiftmodule/x86_64-apple-macos.swiftmodule /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/LightTouchServices.build/Objects-normal/x86_64/LightTouchServices.swiftmodule (in target 'LightTouchServices' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/LightTouchServices.swiftmodule/x86_64-apple-macos.swiftdoc /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/LightTouchServices.build/Objects-normal/x86_64/LightTouchServices.swiftdoc (in target 'LightTouchServices' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/LightTouchServices.swiftmodule/x86_64-apple-macos.abi.json /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/LightTouchServices.build/Objects-normal/x86_64/LightTouchServices.abi.json (in target 'LightTouchServices' from project 'LightTouchMac')
- Copy /Users/runner/work/_temp/dd-port/Build/Products/Debug/LightTouchServices.swiftmodule/Project/x86_64-apple-macos.swiftsourceinfo /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/LightTouchServices.build/Objects-normal/x86_64/LightTouchServices.swiftsourceinfo (in target 'LightTouchServices' from project 'LightTouchMac')
- ScanDependencies /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/LightTouchServices.build/Objects-normal/x86_64/lockdown-tz.o /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchServices/Lockdown/lockdown-tz.c normal x86_64 c com.apple.compilers.llvm.clang.1_0.compiler (in target 'LightTouchServices' from project 'LightTouchMac')
- ScanDependencies /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/LightTouchServices.build/Objects-normal/x86_64/lockdown-mcinstall.o /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchServices/Lockdown/lockdown-mcinstall.c normal x86_64 c com.apple.compilers.llvm.clang.1_0.compiler (in target 'LightTouchServices' from project 'LightTouchMac')
- ScanDependencies /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/LightTouchServices.build/Objects-normal/x86_64/lockdown-ddi.o /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchServices/Lockdown/lockdown-ddi.c normal x86_64 c com.apple.compilers.llvm.clang.1_0.compiler (in target 'LightTouchServices' from project 'LightTouchMac')
- ScanDependencies /Users/runner/work/_temp/dd-port/Build/Intermediates.noindex/LightTouchMac.build/Debug/LightTouchServices.build/Objects-normal/x86_64/lockdown-ax.o /Users/runner/work/LightTouchMac/LightTouchMac/src/LightTouchServices/Lockdown/lockdown-ax.c normal x86_64 c com.apple.compilers.llvm.clang.1_0.compiler (in target 'LightTouchServices' from project 'LightTouchMac')
- EmitSwiftModule normal x86_64 (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftEmitModule normal x86_64 Emitting\ module\ for\ FirmwareKit (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/StoppedVolumeEdit/StoppedVolumeEdit.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/StorageCapacity/StorageCapacity+Requirement.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/StorageGeneration/OwnedStorageRecord.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/StorageGeneration/StorageGeneration.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/Activation.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/Cydia.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/FinishedSetup.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/Keyboards.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/SystemEdits.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/UDIF/UDIF.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/UDIF/UDIFReader.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VFDecrypt/VFDecrypt.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeMount/DevicePath.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeMount/MountedVolume.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeMount/VolumeFiles.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeMount/VolumeMount.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeRebuild/VolumeExport.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeRebuild/VolumeRebuild.swift (in target 'FirmwareKit' from project 'FirmwareKit')
- SwiftCompile normal x86_64 Compiling\ StoppedVolumeEdit.swift,\ StorageCapacity+Requirement.swift,\ OwnedStorageRecord.swift,\ StorageGeneration.swift,\ Activation.swift,\ Cydia.swift,\ FinishedSetup.swift,\ Keyboards.swift,\ SystemEdits.swift,\ UDIF.swift,\ UDIFReader.swift,\ VFDecrypt.swift,\ DevicePath.swift,\ MountedVolume.swift,\ VolumeFiles.swift,\ VolumeMount.swift,\ VolumeExport.swift,\ VolumeRebuild.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/StoppedVolumeEdit/StoppedVolumeEdit.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/StorageCapacity/StorageCapacity+Requirement.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/StorageGeneration/OwnedStorageRecord.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/StorageGeneration/StorageGeneration.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/Activation.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/Cydia.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/FinishedSetup.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/Keyboards.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/SystemEdits/SystemEdits.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/UDIF/UDIF.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/UDIF/UDIFReader.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VFDecrypt/VFDecrypt.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeMount/DevicePath.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeMount/MountedVolume.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeMount/VolumeFiles.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeMount/VolumeMount.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeRebuild/VolumeExport.swift /Users/runner/work/LightTouchMac/LightTouchMac/src/Packages/FirmwareKit/Sources/FirmwareKit/VolumeRebuild/VolumeRebuild.swift (in target 'FirmwareKit' from project 'FirmwareKit')

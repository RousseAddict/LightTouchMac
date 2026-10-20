// The compiler plugin that serves ObservationCompat's macros.
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ObservationCompatPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [ObservableMacro.self, ObservationTrackedMacro.self, ObservationIgnoredMacro.self]
}

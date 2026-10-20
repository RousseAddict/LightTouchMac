// Big Sur port: SwiftUI 3-5 API the app's views use, for macOS 11's SwiftUI 2, under compat names (codemod.py renames
// the uses). Each uses the real API where the system has it, and the nearest SwiftUI 2 form otherwise. Also the
// bridge that makes views follow ObservationCompat models, which SwiftUI doesn't know: codemod.py wraps every view's
// body in CompatObserving. The app compiles this file; codemod.py links it into the tests/offline targets that compile
// app files.
import ObservationCompat
import SwiftUI

// MARK: - Observation

/// Re-renders `content` when anything it read from a CompatObservable model changes: SwiftUI tracks Observation's
/// models itself, not ObservationCompat's.
struct CompatObserving<Content: View>: View {
    @StateObject private var token = CompatObservationToken()
    private let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        _ = token.version
        return withCompatObservationTracking { content() } onChange: { [weak token] in
            Task { @MainActor in token?.version &+= 1 }
        }
    }
}

@MainActor final class CompatObservationToken: ObservableObject {
    @Published var version = 0
}

/// Observation's `@Bindable` for ObservationCompat models: `$model.property` is a Binding.
@propertyWrapper @dynamicMemberLookup
struct CompatBindable<Model: AnyObject> {
    var wrappedValue: Model

    init(wrappedValue: Model) {
        self.wrappedValue = wrappedValue
    }

    var projectedValue: CompatBindable<Model> { self }

    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Model, Value>) -> Binding<Value> {
        let model = wrappedValue
        return Binding(get: { model[keyPath: keyPath] }, set: { model[keyPath: keyPath] = $0 })
    }
}

// MARK: - Styles

extension Color {
    /// `.tertiary` and `.quaternary` as foreground styles: the label colors they stand for.
    static var compatTertiary: Color { Color(NSColor.tertiaryLabelColor) }
    static var compatQuaternary: Color { Color(NSColor.quaternaryLabelColor) }
}

extension View {
    /// `.foregroundStyle(_:)` with a color (`.secondary`, `.compatTertiary`, `.accentColor` for `.tint`).
    func compatForegroundStyle(_ color: Color) -> some View { foregroundColor(color) }

    @ViewBuilder func compatTextSelectionEnabled() -> some View {
        if #available(macOS 12, *) { textSelection(.enabled) } else { self }
    }

    @ViewBuilder func compatMonospacedDigit() -> some View {
        if #available(macOS 12, *) { monospacedDigit() } else { self }
    }

    @ViewBuilder func compatGroupedFormStyle() -> some View {
        if #available(macOS 13, *) { formStyle(.grouped) } else { self }
    }

    @ViewBuilder func compatScrollDisabled(_ disabled: Bool) -> some View {
        if #available(macOS 13, *) { scrollDisabled(disabled) } else { self }
    }

    @ViewBuilder func compatFileDialogDefaultDirectory(_ url: URL?) -> some View {
        if #available(macOS 14, *) { fileDialogDefaultDirectory(url) } else { self }
    }
}

extension Text {
    /// `Text.foregroundStyle(_:)`, still a Text, so Texts can be concatenated.
    func compatForegroundStyle(_ color: Color) -> Text { foregroundColor(color) }

    func compatMonospacedDigit() -> Text {
        if #available(macOS 12, *) { return monospacedDigit() }
        return self
    }
}

extension Font {
    /// Font's own monospacedDigit() is macOS 11; this keeps codemod.py's rename of the view one harmless here.
    func compatMonospacedDigit() -> Font { monospacedDigit() }
}

// MARK: - Lifecycle

extension View {
    /// `.task(priority:_:)`: runs `action` while the view is on screen, cancelled when it goes.
    @ViewBuilder func compatTask(
        priority: TaskPriority = .userInitiated,
        _ action: @escaping @MainActor @Sendable () async -> Void
    ) -> some View {
        if #available(macOS 12, *) {
            task(priority: priority, action)
        } else {
            modifier(CompatTaskModifier(id: true, action: action))
        }
    }

    /// `.task(id:priority:_:)`: also starts again, cancelling the last run, when `id` changes.
    @ViewBuilder func compatTask<ID: Equatable>(
        id: ID,
        priority: TaskPriority = .userInitiated,
        _ action: @escaping @MainActor @Sendable () async -> Void
    ) -> some View {
        if #available(macOS 12, *) {
            task(id: id, priority: priority, action)
        } else {
            modifier(CompatTaskModifier(id: id, action: action))
        }
    }

    /// `.onChange(of:initial:_:)` (macOS 14) with an action that takes no values.
    @ViewBuilder func compatOnChange<V: Equatable>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View {
        if #available(macOS 14, *) {
            onChange(of: value, initial: initial, action)
        } else {
            modifier(CompatChangeModifier(value: value, initial: initial) { _, _ in action() })
        }
    }

    /// `.onChange(of:initial:_:)` with the old and new values.
    @ViewBuilder func compatOnChange<V: Equatable>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (V, V) -> Void
    ) -> some View {
        if #available(macOS 14, *) {
            onChange(of: value, initial: initial, action)
        } else {
            modifier(CompatChangeModifier(value: value, initial: initial, action: action))
        }
    }

    /// `.onChange(of:)` with the new value (macOS 11's form, deprecated in 14).
    @ViewBuilder func compatOnChange<V: Equatable>(of value: V, initial: Bool = false, _ action: @escaping (V) -> Void)
        -> some View
    {
        if #available(macOS 14, *) {
            onChange(of: value, initial: initial) { _, new in action(new) }
        } else {
            modifier(CompatChangeModifier(value: value, initial: initial) { _, new in action(new) })
        }
    }

    /// `.onGeometryChange(for:of:action:)` (macOS 13 here): `action` gets `transform` of the view's geometry when it
    /// changes, and when the view appears.
    @ViewBuilder func compatOnGeometryChange<T: Equatable & Sendable>(
        for type: T.Type,
        of transform: @escaping @Sendable (GeometryProxy) -> T,
        action: @escaping (T) -> Void
    ) -> some View {
        if #available(macOS 13, *) {
            onGeometryChange(for: type, of: transform, action: action)
        } else {
            background(
                GeometryReader { proxy in
                    Color.clear.preference(key: CompatGeometryKey<T>.self, value: transform(proxy))
                }
            )
            .onPreferenceChange(CompatGeometryKey<T>.self) { value in
                if let value = value { action(value) }
            }
        }
    }
}

private struct CompatTaskModifier<ID: Equatable>: ViewModifier {
    let id: ID
    let action: @MainActor @Sendable () async -> Void
    @State private var running: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .onAppear { restart() }
            .onDisappear {
                running?.cancel()
                running = nil
            }
            .onChange(of: id) { _ in restart() }
    }

    private func restart() {
        running?.cancel()
        running = Task { @MainActor in await action() }
    }
}

private struct CompatChangeModifier<V: Equatable>: ViewModifier {
    let value: V
    let initial: Bool
    let action: (V, V) -> Void
    @State private var previous: V?

    func body(content: Content) -> some View {
        content
            .onAppear {
                previous = value
                if initial { action(value, value) }
            }
            .onChange(of: value) { new in
                action(previous ?? new, new)
                previous = new
            }
    }
}

private struct CompatGeometryKey<T: Equatable>: PreferenceKey {
    static var defaultValue: T? { nil }

    static func reduce(value: inout T?, nextValue: () -> T?) {
        value = nextValue() ?? value
    }
}

// MARK: - Views

/// `LabeledContent` (macOS 13): on macOS 11, the label and the content side by side, the label's lines stacked.
struct CompatLabeledContent<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content

    init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self.content = content()
        self.label = label()
    }

    var body: some View {
        if #available(macOS 13, *) {
            LabeledContent {
                content
            } label: {
                label
            }
        } else {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) { label }
                Spacer(minLength: 12)
                content
            }
        }
    }
}

extension CompatLabeledContent where Label == Text {
    init(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(content: content) { Text(titleKey) }
    }

    @_disfavoredOverload
    init<S: StringProtocol>(_ title: S, @ViewBuilder content: () -> Content) {
        self.init(content: content) { Text(title) }
    }
}

extension CompatLabeledContent where Label == Text, Content == Text {
    init<S: StringProtocol>(_ titleKey: LocalizedStringKey, value: S) {
        self.init(content: { Text(value).foregroundColor(.secondary) }) { Text(titleKey) }
    }
}

/// `NavigationSplitView` with a sidebar and a detail (macOS 13); a NavigationView on macOS 11.
struct CompatNavigationSplitView<Sidebar: View, Detail: View>: View {
    private let sidebar: Sidebar
    private let detail: Detail

    init(@ViewBuilder sidebar: () -> Sidebar, @ViewBuilder detail: () -> Detail) {
        self.sidebar = sidebar()
        self.detail = detail()
    }

    var body: some View {
        if #available(macOS 13, *) {
            NavigationSplitView {
                sidebar
            } detail: {
                detail
            }
        } else {
            NavigationView {
                sidebar
                detail
            }
        }
    }
}

extension View {
    @ViewBuilder func compatNavigationSplitViewColumnWidth(min: CGFloat? = nil, ideal: CGFloat, max: CGFloat? = nil)
        -> some View
    {
        if #available(macOS 13, *) {
            navigationSplitViewColumnWidth(min: min, ideal: ideal, max: max)
        } else {
            frame(minWidth: min, idealWidth: ideal, maxWidth: max)
        }
    }
}

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
//
// Modified for Light Touch's Big Sur port (ObservationCompat): the registrar is CompatObservationRegistrar over
// CompatObservable, without availability limits, and without the value-observation storage that only the macOS 26
// Observations sequence uses; Swift 5.5 syntax so the Big Sur Mac builds it. Taken from swiftlang/swift release/6.2
// at 635acfac65e866455abe016b2083b90a34f2d2e3
// (stdlib/public/Observation/Sources/Observation/ObservationRegistrar.swift).

/// Provides storage for tracking and access to data changes, as Observation's `ObservationRegistrar`.
///
/// You don't need to create an instance of `CompatObservationRegistrar` when using the ``CompatObservable()`` macro
/// to indicate observability of a type.
public struct CompatObservationRegistrar: Sendable {
    private struct State: @unchecked Sendable {
        private enum ObservationKind {
            case willSetTracking(@Sendable (AnyKeyPath) -> Void)
            case didSetTracking(@Sendable (AnyKeyPath) -> Void)
        }

        private struct Observation {
            private var kind: ObservationKind
            internal var properties: Set<AnyKeyPath>

            internal init(kind: ObservationKind, properties: Set<AnyKeyPath>) {
                self.kind = kind
                self.properties = properties
            }

            var willSetTracker: (@Sendable (AnyKeyPath) -> Void)? {
                switch kind {
                case .willSetTracking(let tracker):
                    return tracker
                default:
                    return nil
                }
            }

            var didSetTracker: (@Sendable (AnyKeyPath) -> Void)? {
                switch kind {
                case .didSetTracking(let tracker):
                    return tracker
                default:
                    return nil
                }
            }
        }

        private var id = 0
        private var observations = [Int: Observation]()
        private var lookups = [AnyKeyPath: Set<Int>]()

        internal mutating func generateId() -> Int {
            defer { id &+= 1 }
            return id
        }

        internal mutating func registerTracking(
            for properties: Set<AnyKeyPath>, willSet observer: @Sendable @escaping (AnyKeyPath) -> Void
        ) -> Int {
            let id = generateId()
            observations[id] = Observation(kind: .willSetTracking(observer), properties: properties)
            for keyPath in properties {
                lookups[keyPath, default: []].insert(id)
            }
            return id
        }

        internal mutating func registerTracking(
            for properties: Set<AnyKeyPath>, didSet observer: @Sendable @escaping (AnyKeyPath) -> Void
        ) -> Int {
            let id = generateId()
            observations[id] = Observation(kind: .didSetTracking(observer), properties: properties)
            for keyPath in properties {
                lookups[keyPath, default: []].insert(id)
            }
            return id
        }

        internal mutating func cancel(_ id: Int) {
            if let observation = observations.removeValue(forKey: id) {
                for keyPath in observation.properties {
                    if let index = lookups.index(forKey: keyPath) {
                        lookups.values[index].remove(id)
                        if lookups.values[index].isEmpty {
                            lookups.remove(at: index)
                        }
                    }
                }
            }
        }

        internal mutating func cancelAll() {
            observations.removeAll()
            lookups.removeAll()
        }

        internal mutating func willSet(keyPath: AnyKeyPath) -> [@Sendable (AnyKeyPath) -> Void] {
            var trackers = [@Sendable (AnyKeyPath) -> Void]()
            if let ids = lookups[keyPath] {
                for id in ids {
                    if let tracker = observations[id]?.willSetTracker {
                        trackers.append(tracker)
                    }
                }
            }
            return trackers
        }

        internal mutating func didSet<Subject: CompatObservable, Member>(
            keyPath: KeyPath<Subject, Member>
        ) -> [@Sendable (AnyKeyPath) -> Void] {
            var trackers = [@Sendable (AnyKeyPath) -> Void]()
            if let ids = lookups[keyPath] {
                for id in ids {
                    if let tracker = observations[id]?.didSetTracker {
                        trackers.append(tracker)
                    }
                }
            }
            return trackers
        }
    }

    internal struct Context: Sendable {
        private let state = _ManagedCriticalState(State())

        internal var id: ObjectIdentifier { state.id }

        internal func registerTracking(
            for properties: Set<AnyKeyPath>, willSet observer: @Sendable @escaping (AnyKeyPath) -> Void
        ) -> Int {
            state.withCriticalRegion { $0.registerTracking(for: properties, willSet: observer) }
        }

        internal func registerTracking(
            for properties: Set<AnyKeyPath>, didSet observer: @Sendable @escaping (AnyKeyPath) -> Void
        ) -> Int {
            state.withCriticalRegion { $0.registerTracking(for: properties, didSet: observer) }
        }

        internal func cancel(_ id: Int) {
            state.withCriticalRegion { $0.cancel(id) }
        }

        internal func cancelAll() {
            state.withCriticalRegion { $0.cancelAll() }
        }

        internal func willSet<Subject: CompatObservable, Member>(
            _ subject: Subject,
            keyPath: KeyPath<Subject, Member>
        ) {
            let tracking = state.withCriticalRegion { $0.willSet(keyPath: keyPath) }
            for action in tracking {
                action(keyPath)
            }
        }

        internal func didSet<Subject: CompatObservable, Member>(
            _ subject: Subject,
            keyPath: KeyPath<Subject, Member>
        ) {
            let tracking = state.withCriticalRegion { $0.didSet(keyPath: keyPath) }
            for action in tracking {
                action(keyPath)
            }
        }
    }

    private final class Extent: @unchecked Sendable {
        let context = Context()

        init() {}

        deinit {
            context.cancelAll()
        }
    }

    internal var context: Context {
        return extent.context
    }

    private var extent = Extent()

    /// Creates an instance of the observation registrar.
    public init() {}

    /// Registers access to a specific property for observation.
    public func access<Subject: CompatObservable, Member>(
        _ subject: Subject,
        keyPath: KeyPath<Subject, Member>
    ) {
        if let trackingPtr = _ThreadLocal.value?
            .assumingMemoryBound(to: ObservationTracking._AccessList?.self)
        {
            if trackingPtr.pointee == nil {
                trackingPtr.pointee = ObservationTracking._AccessList()
            }
            trackingPtr.pointee?.addAccess(keyPath: keyPath, context: context)
        }
    }

    /// A property observation called before setting the value of the subject.
    public func willSet<Subject: CompatObservable, Member>(
        _ subject: Subject,
        keyPath: KeyPath<Subject, Member>
    ) {
        context.willSet(subject, keyPath: keyPath)
    }

    /// A property observation called after setting the value of the subject.
    public func didSet<Subject: CompatObservable, Member>(
        _ subject: Subject,
        keyPath: KeyPath<Subject, Member>
    ) {
        context.didSet(subject, keyPath: keyPath)
    }

    /// Identifies mutations to the transactions registered for observers: `willSet` before the mutation, `didSet`
    /// after it.
    public func withMutation<Subject: CompatObservable, Member, T>(
        of subject: Subject,
        keyPath: KeyPath<Subject, Member>,
        _ mutation: () throws -> T
    ) rethrows -> T {
        willSet(subject, keyPath: keyPath)
        defer { didSet(subject, keyPath: keyPath) }
        return try mutation()
    }
}

extension CompatObservationRegistrar: Codable {
    public init(from decoder: Decoder) throws {
        self.init()
    }

    public func encode(to encoder: Encoder) {
        // Don't encode a registrar's transient state.
    }
}

extension CompatObservationRegistrar: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        // A registrar should be ignored for the purposes of determining its parent type's equality.
        return true
    }

    public func hash(into hasher: inout Hasher) {
        // Don't include a registrar's transient state in its parent type's hash value.
    }
}

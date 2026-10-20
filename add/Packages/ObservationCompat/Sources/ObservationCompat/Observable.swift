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
// Modified for Light Touch's Big Sur port (ObservationCompat): Observation's protocol and macros under Compat
// names, without availability limits; the macro declarations are compiled only by Swift 5.9 and later, so the
// runtime also builds with the Big Sur Mac's Swift 5.5. Taken from swiftlang/swift release/6.2 at
// 635acfac65e866455abe016b2083b90a34f2d2e3 (stdlib/public/Observation/Sources/Observation/Observable.swift).

/// A type that emits notifications to observers when underlying data changes, as Observation's `Observable`.
/// Apply the ``CompatObservable()`` macro rather than conforming by hand.
public protocol CompatObservable {}

#if compiler(>=5.9)
/// Defines and implements conformance of the CompatObservable protocol, as Observation's `@Observable`.
@attached(
    member, names: named(_$observationRegistrar), named(access), named(withMutation), named(shouldNotifyObservers))
@attached(memberAttribute)
@attached(extension, conformances: CompatObservable)
public macro CompatObservable() = #externalMacro(module: "ObservationCompatMacros", type: "ObservableMacro")

/// Synthesizes a property's tracking accessors; ``CompatObservable()`` applies it.
@attached(accessor, names: named(init), named(get), named(set), named(_modify))
@attached(peer, names: prefixed(_))
public macro CompatObservationTracked() =
    #externalMacro(module: "ObservationCompatMacros", type: "ObservationTrackedMacro")

/// Disables observation tracking of a property, as Observation's `@ObservationIgnored`.
@attached(accessor)
public macro CompatObservationIgnored() =
    #externalMacro(module: "ObservationCompatMacros", type: "ObservationIgnoredMacro")
#endif

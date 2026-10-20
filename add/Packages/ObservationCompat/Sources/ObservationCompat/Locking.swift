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
// Modified for Light Touch's Big Sur port (ObservationCompat): the lock is an os_unfair_lock in the buffer's
// elements, where the original calls C++ shims around swift::Mutex (Locking.cpp). Taken from swiftlang/swift
// release/6.2 at 635acfac65e866455abe016b2083b90a34f2d2e3 (stdlib/public/Observation/Sources/Observation).

import os

internal struct _ManagedCriticalState<State> {
    final private class LockedBuffer: ManagedBuffer<State, os_unfair_lock> {}

    private let buffer: ManagedBuffer<State, os_unfair_lock>

    internal init(_ initial: State) {
        buffer = LockedBuffer.create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointerToElements { $0.initialize(to: os_unfair_lock()) }
            return initial
        }
    }

    internal func withCriticalRegion<R>(_ critical: (inout State) throws -> R) rethrows -> R {
        try buffer.withUnsafeMutablePointers { header, lock in
            os_unfair_lock_lock(lock)
            defer { os_unfair_lock_unlock(lock) }
            return try critical(&header.pointee)
        }
    }
}

extension _ManagedCriticalState: @unchecked Sendable where State: Sendable {}

extension _ManagedCriticalState: Identifiable {
    internal var id: ObjectIdentifier { ObjectIdentifier(buffer) }
}

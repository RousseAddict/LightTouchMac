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
// Modified for Light Touch's Big Sur port (ObservationCompat): a pthread key holds the pointer, where the original
// calls C++ shims around the runtime's thread-local (ThreadLocal.cpp). Taken from swiftlang/swift release/6.2 at
// 635acfac65e866455abe016b2083b90a34f2d2e3 (stdlib/public/Observation/Sources/Observation/ThreadLocal.swift).

import Darwin

/// The access list that `withCompatObservationTracking` is collecting on this thread, if any.
struct _ThreadLocal {
    private static let key: pthread_key_t = {
        var key = pthread_key_t()
        let status = pthread_key_create(&key, nil)
        precondition(status == 0, "ObservationCompat: pthread_key_create failed (\(status))")
        return key
    }()

    static var value: UnsafeMutableRawPointer? {
        get { pthread_getspecific(key) }
        set { pthread_setspecific(key, newValue) }
    }
}

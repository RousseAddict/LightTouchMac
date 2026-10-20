// macOS 13's OSAllocatedUnfairLock for macOS 11: an os_unfair_lock at a fixed heap address, guarding a state. It is a
// class where Apple's is a struct around one, which is the same thing to its users: copies share the lock. Its
// closures aren't required to be @Sendable, so everything that compiled against Apple's compiles against it.
import os

public final class CompatUnfairLock<State>: @unchecked Sendable {
    private let lock: UnsafeMutablePointer<os_unfair_lock>
    private var state: State

    public init(initialState: State) {
        lock = .allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
        state = initialState
    }

    public convenience init(uncheckedState: State) {
        self.init(initialState: uncheckedState)
    }

    deinit {
        lock.deinitialize(count: 1)
        lock.deallocate()
    }

    public func withLock<R>(_ body: (inout State) throws -> R) rethrows -> R {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        return try body(&state)
    }

    public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
        try withLock(body)
    }

    public func withLockCompat<R>(_ body: (inout State) throws -> R) rethrows -> R {
        try withLock(body)
    }
}

extension CompatUnfairLock where State == Void {
    public convenience init() {
        self.init(initialState: ())
    }

    public func withLock<R>(_ body: () throws -> R) rethrows -> R {
        try withLock { (_: inout Void) in try body() }
    }
}

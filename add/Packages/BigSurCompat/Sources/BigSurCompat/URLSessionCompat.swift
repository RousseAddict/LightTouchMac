// macOS 12's async URLSession calls, for macOS 11, on completion-handler tasks: data(for:) and download(for:delegate:),
// each cancelled with the calling task. A download's progress goes to `delegate` through a session of its own (a
// per-task delegate is macOS 12 too), and its file is moved out of URLSession's temporary location, which URLSession
// deletes once it has reported it; the caller owns the file returned, as with download(for:delegate:).
import Foundation

extension URLSession {
    /// Stands in for `data(for:)`.
    public func compatData(for request: URLRequest) async throws -> (Data, URLResponse) {
        let box = TaskBox()
        return try await withCompatCancellation({ box.cancel() }) {
            try await withCheckedThrowingContinuation { continuation in
                let task = self.dataTask(with: request) { data, response, error in
                    if let data = data, let response = response {
                        continuation.resume(returning: (data, response))
                    } else {
                        continuation.resume(throwing: error ?? URLError(.badServerResponse))
                    }
                }
                box.start(task)
            }
        }
    }

    /// Stands in for `download(for:delegate:)`, with the delegate told of progress (didWriteData) and the finish.
    public func compatDownload(for request: URLRequest, delegate: URLSessionDownloadDelegate? = nil) async throws
        -> (URL, URLResponse)
    {
        let forwarder = DownloadForwarder(delegate: delegate)
        let session = URLSession(configuration: configuration, delegate: forwarder, delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }
        let box = TaskBox()
        return try await withCompatCancellation({ box.cancel() }) {
            try await withCheckedThrowingContinuation { continuation in
                forwarder.continuation = continuation
                box.start(session.downloadTask(with: request))
            }
        }
    }
}

/// The task to cancel, which may be cancelled before it exists.
private final class TaskBox: @unchecked Sendable {
    private let lock = NSLock()
    private var task: URLSessionTask?
    private var cancelled = false

    func start(_ task: URLSessionTask) {
        lock.lock()
        self.task = task
        let cancelled = self.cancelled
        lock.unlock()
        task.resume()
        if cancelled { task.cancel() }
    }

    func cancel() {
        lock.lock()
        cancelled = true
        let task = self.task
        lock.unlock()
        task?.cancel()
    }
}

private final class DownloadForwarder: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    let delegate: URLSessionDownloadDelegate?
    var continuation: CheckedContinuation<(URL, URLResponse), Error>?  // set before the task starts
    private var file: Result<URL, Error>?

    init(delegate: URLSessionDownloadDelegate?) {
        self.delegate = delegate
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
        let kept = FileManager.default.temporaryDirectory.appendingPathComponent("CompatDownload-\(UUID().uuidString)")
            .appendingPathExtension(location.pathExtension)
        file = Result { try FileManager.default.moveItem(at: location, to: kept) }.map { kept }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        delegate?.urlSession?(
            session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten,
            totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let continuation = continuation else { return }
        self.continuation = nil
        if let error = error {
            if case .success(let url) = file { try? FileManager.default.removeItem(at: url) }
            return continuation.resume(throwing: error)
        }
        switch (file, task.response) {
        case (.success(let url), let response?):
            continuation.resume(returning: (url, response))
        case (.failure(let error), _):
            continuation.resume(throwing: error)
        default:
            continuation.resume(throwing: URLError(.badServerResponse))
        }
    }
}

/// withTaskCancellationHandler, whose labels changed in Swift 5.7.
func withCompatCancellation<T>(_ onCancel: @escaping @Sendable () -> Void, _ operation: () async throws -> T)
    async throws -> T
{
    #if compiler(>=5.7)
        return try await withTaskCancellationHandler(operation: operation, onCancel: onCancel)
    #else
        return try await withTaskCancellationHandler(handler: onCancel, operation: operation)
    #endif
}

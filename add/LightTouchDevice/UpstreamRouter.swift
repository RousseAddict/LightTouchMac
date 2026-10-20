// Big Sur port: macOS 11 has no per-task URLSession delegate (URLSessionTask.delegate is macOS 12), so the web
// proxy's session gets this one delegate, which hands each task's callbacks to that task's Upstream.
// patches/03-helper-proxy.patch registers each Upstream before its task resumes. A task nobody registered gets
// URLSession's defaults, as it did with no session delegate.
import Foundation

final class UpstreamRouter: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private var upstreams: [Int: Upstream] = [:]

    /// Routes `task`'s callbacks to `upstream`, until the task completes.
    static func route(_ task: URLSessionTask, to upstream: Upstream, in session: URLSession) {
        guard let router = session.delegate as? UpstreamRouter else { return }
        router.lock.lock()
        router.upstreams[task.taskIdentifier] = upstream
        router.lock.unlock()
    }

    private func upstream(for task: URLSessionTask, removing: Bool = false) -> Upstream? {
        lock.lock()
        defer { lock.unlock() }
        return removing ? upstreams.removeValue(forKey: task.taskIdentifier) : upstreams[task.taskIdentifier]
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard let upstream = upstream(for: dataTask) else { return completionHandler(.allow) }
        upstream.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        upstream(for: dataTask)?.urlSession(session, dataTask: dataTask, didReceive: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        upstream(for: task, removing: true)?.urlSession(session, task: task, didCompleteWithError: error)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        guard let upstream = upstream(for: task) else { return completionHandler(request) }
        upstream.urlSession(
            session, task: task, willPerformHTTPRedirection: response, newRequest: request,
            completionHandler: completionHandler)
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse,
        completionHandler: @escaping (CachedURLResponse?) -> Void
    ) {
        guard let upstream = upstream(for: dataTask) else { return completionHandler(proposedResponse) }
        upstream.urlSession(
            session, dataTask: dataTask, willCacheResponse: proposedResponse, completionHandler: completionHandler)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let upstream = upstream(for: task) else { return completionHandler(.performDefaultHandling, nil) }
        upstream.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    }
}

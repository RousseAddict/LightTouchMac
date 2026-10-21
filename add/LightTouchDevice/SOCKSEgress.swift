// Big Sur port: the web proxy's egress as macOS 11's URLSession reaches it. URLSessionConfiguration's
// proxyConfigurations is macOS 14, so patches/19-web-proxy-egress.patch gives the proxy's session a SOCKS proxy
// instead (connectionProxyDictionary). macOS 11's URLSession sends every connection to it, plain HTTP too, as SOCKS5
// (RFC 1928). It offers no authentication and username/password, sends the session's credential (RFC 1929), and names
// the destination rather than resolving it. The egress takes only username/password, and the WebProxy closure resolves
// and checks the name with NetworkPolicy, as it does a CONNECT's.
import Darwin

enum SOCKSEgress {
    enum Refusal: Error { case malformed, notAuthorized, notAllowed, unreachable, unsupported }

    /// Whether `fd`'s first byte is SOCKS 5's version (a CONNECT's is "C"), without consuming it.
    static func isSOCKS(_ fd: Int32) -> Bool {
        var byte: UInt8 = 0
        return recv(fd, &byte, 1, MSG_PEEK) == 1 && byte == 5
    }

    /// One SOCKS5 connection on `fd`: the handshake, then `connect` (the destination's socket; nil when it can't be
    /// reached, a throw when it may not be), then `relay` both ways. The caller closes `fd`.
    static func serve(
        _ fd: Int32,
        authorized: (_ user: String, _ password: String) -> Bool,
        connect: (_ host: String, _ port: Int) throws -> Int32?,
        relay: (_ client: Int32, _ remote: Int32) -> Void
    ) throws {
        guard let greeting = read(fd, 2), greeting[0] == 5, let methods = read(fd, Int(greeting[1])) else {
            throw Refusal.malformed
        }
        guard methods.contains(2) else {
            _ = write(fd, [5, 0xFF])  // no acceptable method: this session's credential is the only way in
            throw Refusal.notAuthorized
        }
        guard write(fd, [5, 2]), let version = read(fd, 1), version[0] == 1,
            let userLength = read(fd, 1), let user = read(fd, Int(userLength[0])),
            let passwordLength = read(fd, 1), let password = read(fd, Int(passwordLength[0]))
        else { throw Refusal.malformed }
        guard authorized(String(decoding: user, as: UTF8.self), String(decoding: password, as: UTF8.self)) else {
            _ = write(fd, [1, 1])
            throw Refusal.notAuthorized
        }
        guard write(fd, [1, 0]), let request = read(fd, 4), request[0] == 5 else { throw Refusal.malformed }
        guard request[1] == 1 else {  // CONNECT only
            reply(fd, 7)
            throw Refusal.unsupported
        }
        let host: String
        switch request[3] {
        case 1:
            guard let address = read(fd, 4) else { throw Refusal.malformed }
            host = address.map(String.init).joined(separator: ".")
        case 3:
            guard let length = read(fd, 1), length[0] > 0, let name = read(fd, Int(length[0])) else {
                throw Refusal.malformed
            }
            host = String(decoding: name, as: UTF8.self)
        case 4:
            guard let address = read(fd, 16) else { throw Refusal.malformed }
            var text = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
            guard inet_ntop(AF_INET6, address, &text, socklen_t(text.count)) != nil else { throw Refusal.malformed }
            host = String(cString: text)
        default:
            reply(fd, 8)
            throw Refusal.unsupported
        }
        guard let portBytes = read(fd, 2) else { throw Refusal.malformed }
        let port = Int(portBytes[0]) << 8 | Int(portBytes[1])
        let remote: Int32?
        do {
            remote = try connect(host, port)
        } catch {
            reply(fd, 2)  // connection not allowed by ruleset
            throw Refusal.notAllowed
        }
        guard let remote = remote, remote >= 0 else {
            reply(fd, 4)  // host unreachable
            throw Refusal.unreachable
        }
        defer { close(remote) }
        guard reply(fd, 0) else { return }
        relay(fd, remote)
    }

    /// A reply with no bound address (0.0.0.0:0): URLSession reads only its status.
    @discardableResult
    private static func reply(_ fd: Int32, _ status: UInt8) -> Bool {
        write(fd, [5, status, 0, 1, 0, 0, 0, 0, 0, 0])
    }

    private static func read(_ fd: Int32, _ count: Int) -> [UInt8]? {
        var bytes = [UInt8](repeating: 0, count: count)
        var got = 0
        while got < count {
            let n = bytes.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress! + got, count - got) }
            if n <= 0 { return nil }
            got += n
        }
        return bytes
    }

    private static func write(_ fd: Int32, _ bytes: [UInt8]) -> Bool {
        bytes.withUnsafeBytes { Darwin.write(fd, $0.baseAddress, bytes.count) } == bytes.count
    }
}

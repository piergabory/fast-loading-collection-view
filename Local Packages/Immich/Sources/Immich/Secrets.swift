public protocol Secrets: Sendable {
    var serverURL: String { get }
    var ownerID: String { get }
    var apiKey: String { get }
}

public nonisolated(unsafe) var apiSecrets: (any Secrets)!

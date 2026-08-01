public struct Page<Item: Codable & Sendable>: Codable, Sendable {
    public let count: Int
    public let items: [Item]
    public let nextPage: String?
}

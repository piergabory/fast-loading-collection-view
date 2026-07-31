public struct AssetPage: Codable, Sendable {
    public let count: Int
    public let items: [Asset]
    public let nextPage: String?
}

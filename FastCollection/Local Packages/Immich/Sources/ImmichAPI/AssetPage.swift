public struct AssetPage: Decodable {
    public let count: Int
    public let items: [Asset]
    public let nextPage: String?
}

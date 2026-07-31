public struct SearchRequest: Encodable {
    public let ownerId: String
    public let tagIds: [String]
    public let type = "IMAGE"
    public let order = "desc"
    public let page: Int
    public let size: Int
}

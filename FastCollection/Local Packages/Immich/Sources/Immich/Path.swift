import ImmichAPI

struct Path {
    let components: [String]

    static let tags = Path(components: ["tags"])

    static let metadata = Path(components: ["search", "metadata"])

    static func thumbnail(id: Asset.ID) -> Self {
        Path(components: ["assets", id, "thumbnail"])
    }
}

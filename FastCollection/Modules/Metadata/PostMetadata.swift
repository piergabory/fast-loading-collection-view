import ImmichAPI

struct PostMetadata: Identifiable, Sendable {
    let front: AssetMetadata
    let back: AssetMetadata

    let nextFrontPage: String?
    let nextBackPage: String?

    nonisolated var id: String {
        front.id + back.id
    }
}

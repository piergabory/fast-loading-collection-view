import ImmichAPI

struct Post: Identifiable, Sendable {
    let front: Asset
    let back: Asset

    let nextFrontPage: String?
    let nextBackPage: String?

    var id: String {
        front.id + back.id
    }
}

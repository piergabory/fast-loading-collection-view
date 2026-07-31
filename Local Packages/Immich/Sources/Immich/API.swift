import ImmichAPI
import Foundation

public struct SearchRequestBody: Encodable, Sendable {
    let ownerId: String
    let tagIds: [Tag.ID]
    let type = "IMAGE"
    let order = "desc"
    let page: Int?
    let size: Int
}

extension Request where Body == SearchRequestBody {
    public static func searchAssets(
        with tagIds: [Tag.ID],
        page: Int?,
        size: Int = 100
    ) async throws -> SearchResponse {
        let body = SearchRequestBody(
            ownerId: apiSecrets.ownerID,
            tagIds: tagIds,
            page: page,
            size: size
        )

        return try await Request(path: .metadata, body: body).send()
    }
}

extension Request where Body == Never {
    public static func tags() async throws -> [Tag] {
        try await Request(path: .tags).send(expecting: [Tag].self)
    }

    public static func thumbnail(for assetID: Asset.ID) async throws -> Data {
        try await Request(path: .thumbnail(id: assetID)).send()
    }
}

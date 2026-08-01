import Foundation
import Immich
import ImmichAPI

final class AssetMetadataPageLoader: Sendable {
    struct Failure: Error { }
    typealias Cache = DiskCache<Page<AssetMetadata>>

    static let firstPage = "Initial"
    private let pageSize = 250
    
    private let diskCache: Cache
    private let tagIds: [Tag.ID]

    private(set) var loadedPages: [String: Page<AssetMetadata>] = [:]
    private(set) var nextPage: String? = firstPage

    init(tagIds: [Tag.ID]) throws {
        let salt = String(tagIds.joined(separator: "-").prefix(16))
        self.diskCache = try Cache(name: "metadata-\(salt)")
        self.tagIds = tagIds
    }

    func loadLocalPages() async {
        var cursor = self.nextPage
        while let key = cursor {
            let page = try? await diskCache.get(key)
            loadedPages[key] = page
            cursor = page?.nextPage
        }
    }

    func loadNextPage() async throws {
        guard let nextPage else { return }
        var page = loadedPages[nextPage]

        if page == nil {
            page = try? await diskCache.get(nextPage)
        }

        if page == nil {
            page = try await loadFromRemote(nextPage)
        }

        guard let page else {
            throw Failure()
        }
        loadedPages[nextPage] = page
        self.nextPage = page.nextPage
    }

    func flush() async throws {
        try await diskCache.flush()
        loadedPages = [:]
        nextPage = Self.firstPage
    }

    private func loadFromRemote(_ key: String?) async throws -> Page<AssetMetadata> {
        if tagIds.isEmpty { throw Failure() }

        let result = try await Request.searchAssets(
            with: tagIds,
            page: key.flatMap { Int($0) },
            size: pageSize
        )
        return result.assets
    }
}

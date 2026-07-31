import Foundation
import Immich
import ImmichAPI

final class PageLoader: Sendable {
    struct Failure: Error { }

    static let firstPage = "Initial"

    private let pageSize = 250
    private let diskCache: PageDiskCache
    private let tagIds: [Tag.ID]

    private(set) var loadedPages: [String: AssetPage] = [:]
    private(set) var nextPage: String? = firstPage

    init(tagIds: [Tag.ID]) throws {
        self.tagIds = tagIds
        self.diskCache = try PageDiskCache(
            name: String(tagIds.joined(separator: "-").prefix(16))
        )
    }

    func loadLocalPages() async {
        var cursor = self.nextPage
        while let key = cursor {
            let page = await diskCache.get(key)
            loadedPages[key] = page
            cursor = page?.nextPage
        }
    }

    func loadNextPage() async throws {
        guard let nextPage else { return }
        var page = loadedPages[nextPage]

        if page == nil {
            page = await diskCache.get(nextPage)
        }

        if page == nil {
            page = try await loadFromRemote(nextPage)
        }

        guard let page else { throw Failure() }
        loadedPages[nextPage] = page
        self.nextPage = page.nextPage
    }

    func deleteStorage() async throws {
        try await diskCache.deleteAll()
        loadedPages = [:]
        nextPage = Self.firstPage
    }

    private func loadFromRemote(_ key: String?) async throws -> AssetPage {
        if tagIds.isEmpty { throw Failure() }

        let result = try await Request.searchAssets(
            with: tagIds,
            page: key.flatMap { Int($0) },
            size: pageSize
        )
        return result.assets
    }
}

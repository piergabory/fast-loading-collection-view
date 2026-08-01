import ImmichAPI
import Observation
import SwiftUI

@MainActor @Observable
final class PostMetadataLoader {
    private typealias Loader = AssetMetadataPageLoader

    private let frontMetadataLoader: Loader
    private let backMetadataLoader: Loader

    fileprivate static var dummy = try! PostMetadataLoader(frontTags: [], backTags: [])

    private(set) var isLoading = false
    private(set) var posts: [PostMetadata] = []

    var didReachEnd: Bool {
        frontMetadataLoader.nextPage == nil || backMetadataLoader.nextPage == nil
    }

    init(frontTags: [Tag.ID], backTags: [Tag.ID]) throws {
        self.frontMetadataLoader = try Loader(tagIds: frontTags)
        self.backMetadataLoader = try Loader(tagIds: backTags)
    }

    func loadMorePosts(after post: PostMetadata) async throws {
        if post.nextBackPage != backMetadataLoader.nextPage { return }
        if post.nextFrontPage != frontMetadataLoader.nextPage { return }
        try await loadNextPage()
    }

    func loadNextPage() async throws {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }

        try await withThrowingTaskGroup { [frontMetadataLoader, backMetadataLoader] group in
            group.addTask { try await frontMetadataLoader.loadNextPage() }
            group.addTask { try await backMetadataLoader.loadNextPage() }
            try await group.waitForAll()
        }
        rebuildPostArray()
    }


    func preload() async throws {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }
        await withTaskGroup { [frontMetadataLoader, backMetadataLoader] group in
            group.addTask { await frontMetadataLoader.loadLocalPages() }
            group.addTask { await backMetadataLoader.loadLocalPages() }
            await group.waitForAll()
        }

        // If No posts are available on disk, fetch off network.
        try await withThrowingTaskGroup { [frontMetadataLoader, backMetadataLoader] group in
            if frontMetadataLoader.loadedPages.isEmpty {
                group.addTask { try await frontMetadataLoader.loadNextPage() }
            }
            if backMetadataLoader.loadedPages.isEmpty {
                group.addTask { try await backMetadataLoader.loadNextPage() }
            }
            try await group.waitForAll()
        }

        rebuildPostArray()
    }

    func flush() async throws {
        try await frontMetadataLoader.flush()
        try await backMetadataLoader.flush()
        posts = []
    }

    private func rebuildPostArray() {
        let fLoadedPages = frontMetadataLoader.loadedPages
        let bLoadedPages = backMetadataLoader.loadedPages

        var fPageKey = Loader.firstPage
        var bPageKey = Loader.firstPage
        var posts: [PostMetadata] = []

        while
            let fPage = fLoadedPages[fPageKey],
            let bPage = bLoadedPages[bPageKey]
        {
            posts += zip(fPage.items, bPage.items).map { front, back in
                PostMetadata(
                    front: front,
                    back: back,
                    nextFrontPage: fPage.nextPage,
                    nextBackPage: bPage.nextPage,
                )
            }
            if let fk = fPage.nextPage, let bk = bPage.nextPage {
                fPageKey = fk
                bPageKey = bk
            } else {
                // reached the last page.
                break
            }
        }

        self.posts = posts
    }
}

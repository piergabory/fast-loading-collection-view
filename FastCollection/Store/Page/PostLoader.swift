import ImmichAPI
import Observation
import SwiftUI

extension EnvironmentValues {
    @Entry
    var postLoader = PostLoader.dummy
}


@MainActor @Observable
final class PostLoader {
    private let frontLoader: PageLoader
    private let backLoader: PageLoader

    fileprivate static var dummy = try! PostLoader(frontTags: [], backTags: [])

    private(set) var isLoading = false
    private(set) var posts: [Post] = []

    var didReachEnd: Bool {
        frontLoader.nextPage == nil || backLoader.nextPage == nil
    }

    init(frontTags: [Tag.ID], backTags: [Tag.ID]) throws {
        self.frontLoader = try PageLoader(tagIds: frontTags)
        self.backLoader = try PageLoader(tagIds: backTags)
    }

    func loadMorePosts(after post: Post) async throws {
        if post.nextBackPage != backLoader.nextPage { return }
        if post.nextFrontPage != frontLoader.nextPage { return }
        try await loadNextPage()
    }

    func loadNextPage() async throws {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }

        try await withThrowingTaskGroup { [frontLoader, backLoader] group in
            group.addTask { try await frontLoader.loadNextPage() }
            group.addTask { try await backLoader.loadNextPage() }
            try await group.waitForAll()
        }
        rebuildPostArray()
    }


    func preload() async throws {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }
        await withTaskGroup { [frontLoader, backLoader] group in
            group.addTask { await frontLoader.loadLocalPages() }
            group.addTask { await backLoader.loadLocalPages() }
            await group.waitForAll()
        }

        // If No posts are available on disk, fetch off network.
        try await withThrowingTaskGroup { [frontLoader, backLoader] group in
            if frontLoader.loadedPages.isEmpty {
                group.addTask { try await frontLoader.loadNextPage() }
            }
            if backLoader.loadedPages.isEmpty {
                group.addTask { try await backLoader.loadNextPage() }
            }
            try await group.waitForAll()
        }

        rebuildPostArray()
    }

    func deleteStorage() async throws {
        try await frontLoader.deleteStorage()
        try await backLoader.deleteStorage()
        posts = []
    }

    private func rebuildPostArray() {
        let fLoadedPages = frontLoader.loadedPages
        let bLoadedPages = backLoader.loadedPages

        var fPageKey = PageLoader.firstPage
        var bPageKey = PageLoader.firstPage
        var posts: [Post] = []

        while
            let fPage = fLoadedPages[fPageKey],
            let bPage = bLoadedPages[bPageKey]
        {
            posts += zip(fPage.items, bPage.items).map { front, back in
                Post(
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

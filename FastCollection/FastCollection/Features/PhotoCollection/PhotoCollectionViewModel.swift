import Observation
import Immich
import ImmichAPI
import Foundation

@Observable
final class PhotoCollectionViewModel {
    var backTagIDs: [Tag.ID] = []
    var frontTagIDs: [Tag.ID] = []

    @ObservationIgnored
    private var frontPages: [String: AssetPage] = [:]

    @ObservationIgnored
    private var backPages: [String: AssetPage] = [:]

    @ObservationIgnored
    private var nextFrontPage: String?

    @ObservationIgnored
    private var nextBackPage: String?

    var errorMessage: String?
    var isLoadingPage = false
    var posts: [Post] = []

    let initialPageId = "Initial"
    let pageSize = 100

    func loadPosts(after post: Post? = nil) async {
        let needsNextPage = post?.nextBackPage == nextBackPage
            || post?.nextFrontPage == nextFrontPage

        if !isLoadingPage, needsNextPage {
            await loadNextPages()
            rebuildPostArray()
        }
    }

    private func rebuildPostArray() {
        var frontKey = initialPageId
        var backKey = initialPageId
        var posts: [Post] = []

        while let front = frontPages[frontKey], let back = backPages[backKey] {
            posts += zip(front.items, back.items).map {
                Post(
                    front: $0,
                    back: $1,
                    nextFrontPage: front.nextPage,
                    nextBackPage: back.nextPage
                )
            }
            guard
                let nextFrontPage = front.nextPage,
                let nextBackPage = back.nextPage
            else { break }

            frontKey = nextFrontPage
            backKey = nextBackPage
        }

        self.posts = posts
    }


    private func loadNextPages() async {
        guard frontPages.isEmpty || nextFrontPage != nil else { return }
        guard backPages.isEmpty || nextBackPage != nil else { return }

        isLoadingPage = true

        async let frontRequest = Request.searchAssets(
            with: frontTagIDs,
            page: nextFrontPage.flatMap { Int($0) },
            size: pageSize,
        )
        async let backRequest = Request.searchAssets(
            with: backTagIDs,
            page: nextBackPage.flatMap { Int($0) },
            size: pageSize,
        )

        do {
            let front = try await frontRequest.assets
            frontPages[nextFrontPage ?? initialPageId] = front
            nextFrontPage = front.nextPage

            let back = try await backRequest.assets
            backPages[nextBackPage ?? initialPageId] = back
            nextBackPage = back.nextPage

            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingPage = false
    }
}

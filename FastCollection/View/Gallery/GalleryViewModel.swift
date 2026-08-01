import Observation

@Observable
final class GalleryViewModel {
    private let preloadingThreshold = 200
    private let preloadingBatchSize = 500

    private let metadataLoader: PostMetadataLoader
    private let thumbnailStore: ThumbnailStore
    private let cacheWarmupService: ThumbnailCacheWarmupService

    @ObservationIgnored
    private var isPreloading = false

    @ObservationIgnored
    private var loadingTask: Task<Void, Never>?

    private(set) var posts: [PostMetadata] = []

    init(
        metadataLoader: PostMetadataLoader,
        thumbnailStore: ThumbnailStore = .global,
    ) {
        self.metadataLoader = metadataLoader
        self.thumbnailStore = thumbnailStore
        self.cacheWarmupService = ThumbnailCacheWarmupService(
            postLoader: metadataLoader,
            postStore: thumbnailStore
        )
    }

    func start() async {
        do {
            try await metadataLoader.preload()
        } catch {
            // TODO: Log? Retry?
        }
        updateThumbnails()
    }

    func loadMore(after post: PostMetadata) {
        loadingTask = Task {
            do {
                try await metadataLoader.loadMorePosts(after: post)
            } catch {
                    // TODO: Log? Retry?
            }
            updateThumbnails()
            preloadIfNeeded(on: post)
        }
    }

    private func updateThumbnails() {
        posts = metadataLoader.posts.reversed()
    }

    private func preloadIfNeeded(on post: PostMetadata) {
        if metadataLoader.didReachEnd || isPreloading { return }

        let postCount = metadataLoader.posts.count
        let threshold = postCount - preloadingThreshold
        let postIndex = metadataLoader.posts.firstIndex { $0.id == post.id }
        guard let postIndex, postIndex > threshold else { return }

        let limit = postCount + preloadingBatchSize
        Task {
            isPreloading = true
            print("Reaching the last page, warming up cache...")

            do {
                try await cacheWarmupService.preloadCache(max: limit)
            } catch {
                print("Cache warmup failed (\(error)).")
            }
            isPreloading = false
        }
    }
}

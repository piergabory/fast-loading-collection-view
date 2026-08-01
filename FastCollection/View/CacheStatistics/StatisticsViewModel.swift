import Observation

@Observable
final class StatisticsViewModel {
    private let metadataLoader: PostMetadataLoader
    private let thumbnailStore: ThumbnailStore
    private let cacheWarmupService: ThumbnailCacheWarmupService

    var isFlushing = false
    var isWarmingUp = false

    var memoryHitCount: Int { thumbnailStore.memoryHitCount }
    var diskHitCount: Int { thumbnailStore.diskHitCount }
    var generationCount: Int { thumbnailStore.generationCount }
    var diskCacheCount: Int { thumbnailStore.diskCacheCount }
    var loadedPostsCount: Int { metadataLoader.posts.count }

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

    func flush() {
        if isFlushing || isWarmingUp {
            return
        }
        Task {
            isFlushing = true
            // TODO: Error Handling?
            try? await metadataLoader.flush()
            try? await thumbnailStore.flushCache()
            try? await thumbnailStore.resetStatistics()
            isFlushing = false
        }
    }

    func warmup() {
        if isFlushing || isWarmingUp {
            return
        }
        Task {
            isWarmingUp = true
            try? await cacheWarmupService.preloadCache()
            isWarmingUp = false
        }
    }

    func start() async {
        try? await thumbnailStore.refreshStatistics()
    }
}

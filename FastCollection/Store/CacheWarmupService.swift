struct CacheWarmupService {
    let postLoader: PostLoader
    let postStore: PostStore

    func preloadCache(max: Int = 1000) async throws {
        try await postLoader.preload()

        for _ in 0...20 {
            if postLoader.posts.count >= max { break }
            try await postLoader.loadNextPage()
        }

        await preloadAllPosts()
        try? await postStore.refreshStatistics()
    }

    private func preloadAllPosts() async {
        let chunks: [[Post]] = postLoader.posts
            .reduce(into: [[]]) { chunks, post in
                chunks[0].append(post)
                if chunks.count > 100 {
                    chunks.insert([], at: 0)
                }
            }

        await withTaskGroup(of: Void.self) { group in
            for chunk in chunks {
                group.addTask {
                    await preload(chunk: chunk)
                }
            }
            await group.waitForAll()
        }
    }


    @concurrent
    private func preload(chunk posts: [Post]) async {
        for (index, post) in posts.enumerated() {
            do {
                try await postStore.get(post)
                if index.isMultiple(of: 10) {
                    try? await postStore.refreshStatistics()
                }
            } catch {
                print("Preloading error post \(post.id): \(error)")
            }
        }
    }
}

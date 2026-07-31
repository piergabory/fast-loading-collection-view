import UIKit.UIImage
import SwiftUI

extension EnvironmentValues {
    @Entry
    var postStore = PostStore.global
}

@Observable
final class PostStore {
    private let diskCache = try! DiskCache()
    private let memoryCache = MemoryCache()
    private let postGenerator = PostGenerator()

    static let global = PostStore()

    var diskCacheCount = 0
    var memoryHitCount = 0
    var diskHitCount = 0
    var generationCount = 0

    func get(_ post: Post) async throws -> UIImage {
        if let memoryHit = memoryCache.get(post.id) {
            memoryHitCount += 1
            return memoryHit
        }

        if let diskHit = await diskCache.get(post.id) {
            diskHitCount += 1
            memoryCache.set(post.id, value: diskHit)
            return diskHit
        }

        let generatedPost = try await postGenerator.generate(post)
        store(post: post, asset: generatedPost)
        generationCount += 1
        return generatedPost
    }

    func flushCache() async throws {
        memoryCache.flush()
        try await diskCache.flush()
        try await resetStatistics()
    }

    func resetStatistics() async throws {
        memoryHitCount = 0
        diskHitCount = 0
        generationCount = 0
        try await refreshStatistics()
    }

    func refreshStatistics() async throws {
        diskCacheCount = try await diskCache.count()
    }

    private func store(post: Post, asset: UIImage) {
        Task {
            memoryCache.set(post.id, value: asset)
            await diskCache.set(post.id, value: asset)
        }
    }
}

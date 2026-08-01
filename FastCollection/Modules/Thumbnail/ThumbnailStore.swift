import UIKit.UIImage
import SwiftUI

@Observable
final class ThumbnailStore {
    private let diskCache = try! DiskCache<UIImage>(name: "thumbnails")
    private let memoryCache = MemoryCache()
    private let thumbnailGenerator = ThumbnailGenerator()

    static let global = ThumbnailStore()

    var diskCacheCount = 0
    var memoryHitCount = 0
    var diskHitCount = 0
    var generationCount = 0

    @discardableResult
    func get(_ post: PostMetadata) async throws -> UIImage {
        if let memoryHit = memoryCache.get(post.id) {
            memoryHitCount += 1
            return memoryHit
        }

        if let diskHit = try? await diskCache.get(post.id) {
            diskHitCount += 1
            memoryCache.set(post.id, value: diskHit)
            return diskHit
        }

        let generatedPost = try await thumbnailGenerator.generate(post)
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

    private func store(post: PostMetadata, asset: UIImage) {
        Task {
            memoryCache.set(post.id, value: asset)
            try? await diskCache.set(post.id, image: asset)
        }
    }
}

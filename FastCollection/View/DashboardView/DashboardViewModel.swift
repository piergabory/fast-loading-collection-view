import Foundation
import Immich
import ImmichAPI
import Observation

@Observable @MainActor
final class DashboardViewModel {
    var errorMessage: String?
    var gallery: GalleryViewModel?
    var statistics: StatisticsViewModel?

    func reload() async {
        do {
            let tags = try await Request.tags()
            try process(tags)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func process(_ tags: [Tag]) throws {
        let frontTags = tags
            .filter { $0.value == "BeReal/front" }
            .map { $0.id }
        let backTags = tags
            .filter { $0.value == "BeReal/back" }
            .map { $0.id }

        let postLoader = try PostMetadataLoader(
            frontTags: frontTags,
            backTags: backTags
        )
        let store = ThumbnailStore.global
        gallery = GalleryViewModel(
            metadataLoader: postLoader,
            thumbnailStore: store
        )
        statistics = StatisticsViewModel(
            metadataLoader: postLoader,
            thumbnailStore: store
        )
    }
}

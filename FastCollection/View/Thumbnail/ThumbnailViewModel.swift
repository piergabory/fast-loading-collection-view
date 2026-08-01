import Observation
import UIKit.UIImage

@Observable
final class ThumbnailViewModel: Identifiable {
    private let store = ThumbnailStore.global
    let metadata: PostMetadata

    var id: PostMetadata.ID {
        metadata.id
    }

    private(set) var image: UIImage?

    init(post metadata: PostMetadata) {
        self.metadata = metadata
    }

    func load() async {
        guard image == nil else { return }
        do {
            image = try await store.get(metadata)
        } catch {
            print(error)
            // TODO: Log? Retry?
        }
    }
}

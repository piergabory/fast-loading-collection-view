import Observation
import ImmichAPI
import Immich
import Foundation
import UIKit.UIImage

@Observable
final class ThumbnailViewModel {
    var front: UIImage?
    var back: UIImage?
    var isLoading = false

    func load(_ post: Post) async {
        if isLoading { return }
        isLoading = true

        do {
            let frontData = try await Request.thumbnail(for: post.front.id)
            front = UIImage(data: frontData)
        } catch {
            print(error)
        }

        do {
            let backData = try await Request.thumbnail(for: post.back.id)
            back = UIImage(data: backData)
        } catch {
            if error is CancellationError { return }
            print(error)
        }

        isLoading = false
    }
}

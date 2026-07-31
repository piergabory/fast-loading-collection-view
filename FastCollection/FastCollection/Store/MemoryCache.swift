import Foundation
import UIKit.UIImage

struct MemoryCache {
    private let storage = NSCache<NSString, UIImage>()

    func check(_ postID: Post.ID) -> Bool {
        storage.object(forKey: postID as NSString) != nil
    }

    func flush() {
        storage.removeAllObjects()
    }

    func get(_ postID: Post.ID) -> UIImage? {
        storage.object(forKey: postID as NSString)
    }

    func set(_ postID: Post.ID, value: UIImage) {
        storage.setObject(value, forKey: postID as NSString)
    }
}

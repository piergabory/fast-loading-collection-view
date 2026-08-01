import Foundation
import UIKit.UIImage

struct MemoryCache: Sendable {
    typealias Key = String

    private let storage = NSCache<NSString, UIImage>()

    func check(_ key: Key) -> Bool {
        storage.object(forKey: key as NSString) != nil
    }

    func flush() {
        storage.removeAllObjects()
    }

    func get(_ key: Key) -> UIImage? {
        storage.object(forKey: key as NSString)
    }

    func set(_ key: Key, value: UIImage) {
        storage.setObject(value, forKey: key as NSString)
    }
}

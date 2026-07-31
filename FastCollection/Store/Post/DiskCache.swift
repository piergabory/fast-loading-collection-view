import Foundation
import UIKit.UIImage

actor DiskCache {
    let manager = FileManager.default
    let rootDirectory: URL

    init() throws {
        rootDirectory = manager
            .temporaryDirectory
            .appending(path: "posts")

        try manager.createDirectory(
            at: rootDirectory,
            withIntermediateDirectories: true
        )
    }

    func count() async throws -> Int {
        try manager
            .contentsOfDirectory(
                at: rootDirectory,
                includingPropertiesForKeys: nil
            )
            .count
    }

    func check(_ postID: Post.ID) -> Bool {
        let path = path(for: postID).path()
        return manager.fileExists(atPath: path)
    }

    func flush() throws {
        try manager.removeItem(at: rootDirectory)
        try manager.createDirectory(
            at: rootDirectory,
            withIntermediateDirectories: true
        )
    }

    @concurrent
    func get(_ postID: Post.ID) async -> UIImage? {
        guard await check(postID) else { return nil }

        let path = await path(for: postID)
        do {
            let data = try Data(contentsOf: path)
            return UIImage(data: data)
        } catch {
            print("File cache error:")
            print(error)
            return nil
        }
    }

    func set(_ postID: Post.ID, value: UIImage) {
        let path = path(for: postID).path()
        let data = data(for: value)
        manager.createFile(atPath: path, contents: data)
    }

    private func data(for value: UIImage) -> Data? {
        value.jpegData(compressionQuality: 0.5)
    }

    private func path(for postID: Post.ID) -> URL {
        rootDirectory.appending(components: postID)
    }
}

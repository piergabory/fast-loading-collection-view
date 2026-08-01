import Foundation
import UIKit.UIImage

actor DiskCache<Item> {
    struct Failure: Error {}
    typealias Key = String

    private let manager = FileManager.default
    private let rootDirectory: URL

    init(name: String) throws {
        rootDirectory = manager
            .temporaryDirectory
            .appending(path: name)

        try manager.createDirectory(
            at: rootDirectory,
            withIntermediateDirectories: true,
        )
    }

    func count() async throws -> Int {
        try manager
            .contentsOfDirectory(
                at: rootDirectory,
                includingPropertiesForKeys: nil,
            )
            .count
    }

    func check(_ key: Key) -> Bool {
        let path = path(for: key).path()
        return manager.fileExists(atPath: path)
    }

    func flush() throws {
        try manager.removeItem(at: rootDirectory)
        try manager.createDirectory(
            at: rootDirectory,
            withIntermediateDirectories: true,
        )
    }

    @concurrent
    private func getData(_ key: Key) async throws -> Data? {
        guard await check(key) else { return nil }

        let path = await path(for: key)
        return try Data(contentsOf: path)
    }

    private func set(_ key: Key, data: Data) {
        let path = path(for: key).path()
        manager.createFile(atPath: path, contents: data)
    }

    private func path(for key: Key) -> URL {
        rootDirectory.appending(components: key)
    }
}

extension DiskCache where Item == UIImage {
    func get(_ key: Key) async throws -> UIImage? {
        try await getData(key).flatMap { data in
            UIImage(data: data)
        }
    }

    func set(_ key: Key, image: UIImage) throws {
        if let data = image.jpegData(compressionQuality: 0.5) {
            set(key, data: data)
        } else {
            throw Failure()
        }
    }
}

extension DiskCache where Item: Codable {
    func set(_ key: Key, item: Item) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        set(key, data: data)
    }

    func get(_ key: Key) async throws -> Item? {
        let decoder = JSONDecoder()
        guard let data = try await getData(key) else { return nil }
        return try decoder.decode(Item.self, from: data)
    }
}

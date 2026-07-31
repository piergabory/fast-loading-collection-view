import Foundation
import ImmichAPI

actor PageDiskCache {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let rootDirectory: URL

    init(name: String) throws {
        self.rootDirectory = fileManager
            .temporaryDirectory
            .appending(component: "pages")
            .appending(component: name)

        try fileManager.createDirectory(
            at: rootDirectory,
            withIntermediateDirectories: true
        )
    }

    func get(_ key: String?) async -> AssetPage? {
        let path = rootDirectory.appending(path: key ?? "initial")
        do {
            let data = try Data(contentsOf: path)
            let page = try decoder.decode(AssetPage.self, from: data)
            return page
        } catch {
            return nil
        }
    }

    func set(key: String, page: AssetPage) throws {
        let data = try encoder.encode(page)
        let path = rootDirectory.appending(path: key).path()
        fileManager.createFile(atPath: path, contents: data)
    }

    func deleteAll() async throws {
        try fileManager.removeItem(at: rootDirectory)
        try fileManager.createDirectory(
            at: rootDirectory,
            withIntermediateDirectories: true
        )
    }
}

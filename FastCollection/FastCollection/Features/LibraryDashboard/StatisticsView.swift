import SwiftUI

struct StatisticsView: View {
    @Environment(\.postStore)
    private var store: PostStore

    @State
    private var clearingCache: Task<Void, Error>?

    @State
    private var errorMessage: String?

    private var isClearingCache: Bool {
        clearingCache?.isCancelled == false
    }

    var body: some View {
        Text("Cached posts count: \(store.diskCacheCount)")
            .task { await updateStatistics() }

        Text("Memory hits: \(store.memoryHitCount)")
        Text("Storage hits: \(store.diskHitCount)")
        Text("Generations: \(store.generationCount)")

        clearCacheButton
    }

    private var clearCacheButton: some View {
        Button(
            (isClearingCache ? "Clearing" : "Clear") + "Cache",
            systemImage: "trash"
        ) {
            clearCache()
        }
        .disabled(isClearingCache)
    }

    private func updateStatistics() async {
        do {
            try await store.refreshStatistics()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func clearCache() {
        clearingCache = Task {
            do {
                try await PostStore.global.flushCache()
            } catch {
                errorMessage = error.localizedDescription
            }
            clearingCache = nil
        }
    }
}

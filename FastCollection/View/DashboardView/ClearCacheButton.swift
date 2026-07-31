import SwiftUI

struct ClearCacheButton: View {
    @Environment(\.postStore)
    private var store: PostStore

    @Environment(\.postLoader)
    private var loader: PostLoader

    @State
    private var clearingCache: Task<Void, Error>?

    @State
    private var errorMessage: String?

    private var isClearingCache: Bool {
        clearingCache?.isCancelled == false
    }

    var body: some View {
        HStack {
            Button(
                (isClearingCache ? "Clearing" : "Clear") + " cache",
                systemImage: "trash",
                role: .destructive
            ) {
                clearCache()
            }
            .disabled(isClearingCache)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            if isClearingCache {
                ProgressView()
            }
        }
    }

    private func clearCache() {
        clearingCache = Task {
            do {
                try await store.flushCache()
                try await loader.deleteStorage()
            } catch {
                errorMessage = error.localizedDescription
            }
            clearingCache = nil
        }
    }

}

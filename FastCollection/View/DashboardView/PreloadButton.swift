import SwiftUI

struct PreloadButton: View {
    @Environment(\.postStore)
    private var postStore: PostStore

    @Environment(\.postLoader)
    private var postLoader: PostLoader

    @State
    private var isBusy = false

    @State
    private var errorMessage: String?

    private var warmup: CacheWarmupService {
        CacheWarmupService(postLoader: postLoader, postStore: postStore)
    }

    var body: some View {
        HStack {
            Button("Warm-up Cache", systemImage: "heat.waves") {
                Task { await warmupCache() }
            }
            .disabled(isBusy)
            .frame(maxWidth: .infinity, alignment: .leading)
            if isBusy {
                ProgressView()
            }
        }
    }

    private func warmupCache() async {
        isBusy = true
        do {
            try await warmup.preloadCache()
        } catch {
            errorMessage = error.localizedDescription
        }
        isBusy = false
    }
}

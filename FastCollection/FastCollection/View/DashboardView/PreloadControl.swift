import SwiftUI

struct PreloadControl: View {
    @Environment(\.postStore)
    private var postStore: PostStore

    @Environment(\.postLoader)
    private var postLoader: PostLoader

    @AppStorage("automatic-cache-warmup")
    private var isAuto = true

    @State
    private var isBusy = false

    @State
    private var errorMessage: String?

    private var warmup: CacheWarmupService {
        CacheWarmupService(postLoader: postLoader, postStore: postStore)
    }

    var body: some View {
        Toggle("Automatic warmup", isOn: $isAuto).task {
            if isAuto {
                await warmupCache()
            }
        }
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

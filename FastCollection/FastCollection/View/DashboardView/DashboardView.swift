import Immich
import SwiftUI

struct DashboardView: View {
    private enum LoadState {
        case loading
        case connected
        case failed(String)
    }

    @State
    private var model = DashboardViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Server status") {
                    ConnectionStatusCard(status: model.status)
                    errorMessage
                }
                Section {
                    StatisticsView()
                    PreloadButton()
                    ClearCacheButton()
                } header: {
                    Text("Caching")
                } footer: {
                    Text(
                        """
                        Graph shows where posts are loaded from.
                        - Memory (RAM) is the fastest.
                        - Storage works offline, but isn't always fast \ 
                        enough when the user scrolls too fast.
                        - Network is much slower, the user will noticer. \
                        It's unavoidable, the goal is to minimise it.
                        
                        Warm-up pre-caches some posts, to reduce the \
                        chance of the user seeing a network loader.
                        """
                    )
                }
            }
            .safeAreaBar(edge: .bottom) {
                GoToPhotosButton()
            }
            .task { await model.reload() }
            .refreshable { await model.reload() }
        }
        .environment(\.postLoader, model.postLoader)
    }


    @ViewBuilder
    private var errorMessage: some View {
        if let message = model.errorMessage {
            Text(message)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    DashboardView()
        .colorScheme(.dark)
}

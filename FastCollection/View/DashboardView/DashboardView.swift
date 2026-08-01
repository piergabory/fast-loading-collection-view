import Immich
import SwiftUI

struct DashboardView: View {
    @State
    private var model = DashboardViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    errorMessage
                    if let statistics = model.statistics {
                        StatisticsView(model: statistics)
                    }
                } header: {
                    Text("Caching")
                } footer: {
                    footer
                }
            }
            .safeAreaBar(edge: .bottom) {
                if let gallery = model.gallery {
                    GalleryViewLink(model: gallery)
                }
            }
            .task { await model.reload() }
            .refreshable { await model.reload() }
        }
    }

    private var footer: some View {
        Text(
            """
            Graph shows where posts are loaded from.
            - Memory (RAM) is the fastest.
            - Storage works offline, but isn't always fast \
            enough when the user scrolls too fast.
            - Network is much slower, the user will notice. \
            It's unavoidable, the goal is to minimise it.

            Warm-up pre-caches some posts, to reduce the \
            chance of the user seeing a network loader.
            """
        )
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

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
                ConnectionStatusCard(status: model.status)
                tags(label: "BeReal/front", ids: model.frontTags)
                tags(label: "BeReal/back", ids: model.backTags)
                StatisticsView()
                errorMessage
            }
            .safeAreaBar(edge: .bottom) {
                goToPhotosButton
            }
            .task { await model.reload() }
            .refreshable { await model.reload() }
        }
    }

    private var goToPhotosButton: some View {
        NavigationLink {
            PhotoCollectionView(
                frontTags: model.frontTags,
                backTags: model.backTags
            )
        } label: {
            Text("Photos")
                .bold()
                .frame(height: 32)
        }
        .buttonStyle(.borderedProminent)
        .buttonSizing(.flexible)
        .padding()
    }

    @ViewBuilder
    private func tags(label: String, ids: [String]) -> some View {
        if !ids.isEmpty {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.headline)
                ForEach(ids, id: \.self) { id in
                    Text(id)
                }
            }
        }
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

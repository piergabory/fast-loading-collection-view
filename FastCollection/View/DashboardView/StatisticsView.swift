import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(\.postStore)
    private var store: PostStore

    @Environment(\.postLoader)
    private var loader: PostLoader

    var body: some View {
        VStack(alignment: .leading) {
            Text("Cache hits").font(.headline)
            Chart {
                BarMark(x: .value("Value", store.memoryHitCount), stacking: .normalized)
                    .foregroundStyle(by: .value("Origin", "Memory"))
                BarMark(x: .value("Value", store.diskHitCount), stacking: .normalized)
                    .foregroundStyle(by: .value("Origin", "Storage"))
                BarMark(x: .value("Value", store.generationCount), stacking: .normalized)
                    .foregroundStyle(by: .value("Origin", "Network"))
            }
            .frame(height: 64)
        }
        .task { try? await store.refreshStatistics() }
        LabeledContent("Cache storage entries", value: store.diskCacheCount, format: .number)
        LabeledContent("Loaded posts count", value: loader.posts.count, format: .number)
    }
}

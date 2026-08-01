import SwiftUI
import Charts

struct CacheHitGraph: View {
    @Bindable
    var model: StatisticsViewModel

    var body: some View {
        cacheHitGraph
        counters
    }

    private var cacheHitGraph: some View {
        VStack(alignment: .leading) {
            Text("Cache hits").font(.headline)
            Chart {
                BarMark(x: .value("Value", model.memoryHitCount), stacking: .normalized)
                    .foregroundStyle(by: .value("Origin", "Memory"))
                BarMark(x: .value("Value", model.diskHitCount), stacking: .normalized)
                    .foregroundStyle(by: .value("Origin", "Storage"))
                BarMark(x: .value("Value", model.generationCount), stacking: .normalized)
                    .foregroundStyle(by: .value("Origin", "Network"))
            }
            .frame(height: 64)
        }
    }

    @ViewBuilder
    private var counters: some View {
        LabeledContent(
            "Cache storage entries",
            value: model.diskCacheCount,
            format: .number
        )
        LabeledContent(
            "Loaded posts count",
            value: model.loadedPostsCount,
            format: .number
        )
    }
}

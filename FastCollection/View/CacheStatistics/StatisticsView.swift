import SwiftUI

struct StatisticsView: View {
    @Bindable
    var model: StatisticsViewModel

    var body: some View {
        CacheHitGraph(model: model)
        PreloadButton(model: model)
        ClearCacheButton(model: model)
            .task { await model.start() }
    }
}

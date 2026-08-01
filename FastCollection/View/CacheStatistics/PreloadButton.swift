import SwiftUI

struct PreloadButton: View {
    @Bindable
    var model: StatisticsViewModel

    var body: some View {
        HStack {
            Button("Warm-up Cache", systemImage: "heat.waves") {
                model.warmup()
            }
            .disabled(model.isFlushing)
            .disabled(model.isWarmingUp)
            .frame(maxWidth: .infinity, alignment: .leading)
            if model.isWarmingUp {
                ProgressView()
            }
        }
    }
}

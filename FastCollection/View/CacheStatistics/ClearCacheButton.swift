import SwiftUI

struct ClearCacheButton: View {
    @Bindable
    var model: StatisticsViewModel

    var body: some View {
        HStack {
            Button(
                (model.isFlushing ? "Clearing" : "Clear") + " cache",
                systemImage: "trash",
                role: .destructive,
            ) {
                model.flush()
            }
            .disabled(model.isFlushing)
            .disabled(model.isWarmingUp)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            if model.isFlushing {
                ProgressView()
            }
        }
    }
}

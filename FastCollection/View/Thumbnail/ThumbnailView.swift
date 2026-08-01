import SwiftUI

struct ThumbnailView: View {
    @State
    private var model: ThumbnailViewModel

    init(_ metadata: PostMetadata) {
        self._model = State(wrappedValue: ThumbnailViewModel(post: metadata))
    }

    var body: some View {
        ZStack {
            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(3/4, contentMode: .fill)
        .background(.background.secondary)
        .clipped()
        .foregroundStyle(.fill)
        .task {
            await model.load()
        }
    }
}

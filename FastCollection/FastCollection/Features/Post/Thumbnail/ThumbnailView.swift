import SwiftUI
import ImmichAPI

struct ThumbnailView: View {
    @State
    private var model = ThumbnailViewModel()

    let post: Post

    var body: some View {
        PostContainer {
            photo(model.back)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .topLeading) {
                    frontminiature
                }
                .overlay {
                    if model.isLoading {
                      progress
                    }
                }
        }
        .task {
            await model.load(post)
        }
    }

    private var frontminiature: some View {
        photo(model.front)
            .frame(width: 30, height: 40)
            .border(.primary)
            .padding(4)
    }

    private var progress: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background()
    }

    private func photo(_ asset: UIImage?) -> some View {
        let image = if let asset {
            Image(uiImage: asset)
                .resizable()
        } else {
            Image(systemName: "exclamationmark.triangle")
        }

        return image
    }
}

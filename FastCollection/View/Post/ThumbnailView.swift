import SwiftUI
import ImmichAPI

struct ThumbnailView: View {
    @Environment(\.postStore)
    private var store: PostStore

    @State var asset: UIImage?

    let post: Post

    var body: some View {
        PostContainer {
            let image = if let asset {
                Image(uiImage: asset).resizable()
            } else {
                Image(systemName: "questionmark.circle")
            }

            image
        }
        .task {
            asset = try? await store.get(post)
        }
    }
}

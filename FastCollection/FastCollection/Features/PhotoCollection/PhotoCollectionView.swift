import ImmichAPI
import SwiftUI

struct PhotoCollectionView: View {
    private let columns = Array(
        repeating: GridItem(.flexible()),
        count: 4,
    )

    let frontTags: [Tag.ID]
    let backTags: [Tag.ID]

    @State
    private var model = PhotoCollectionViewModel()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(model.posts) { post in
                    ThumbnailView(post: post)
                        .task {
                            await model.loadPosts(after: post)
                        }
                        .id(post.id)
                }
                if !model.isLoadingPage {
                    ForEach(0..<100) { _ in
                        PlaceholderPostView()
                    }
                }
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .all)
        .safeAreaBar(edge: .top) {
            if let message = model.errorMessage {
                Text(message)
            }
        }
        .task {
            model.backTagIDs = backTags
            model.frontTagIDs = frontTags
            await model.loadPosts()
        }
        .navigationSubtitle("Loaded \(model.posts.count) posts.")
        .background()
    }
}

#Preview {
    NavigationStack {
        PhotoCollectionView(
            frontTags: ["9327ded7-eb63-468a-95e5-9500f5081df1"],
            backTags: ["54392ce6-c1b2-48ea-a384-c6b113413bf3"]
        )
    }
    .colorScheme(.dark)
}

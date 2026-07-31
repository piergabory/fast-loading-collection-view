import ImmichAPI
import SwiftUI

struct PhotoCollectionView: View {
    private let columns = Array(
        repeating: GridItem(.flexible()),
        count: 4,
    )

    @Environment(\.postLoader)
    private var model: PostLoader

    @State
    private var errorMessage: String?

    var body: some View {
        collectionView
            .task { try? await model.preload() }
            .navigationSubtitle("Loaded \(model.posts.count) posts.")
    }

    private var collectionView: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                postThumbnails
                loadingPagePlaceholder
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .all)
        .background()
    }

    private var postThumbnails: some View {
        ForEach(model.posts) { post in
            ThumbnailView(post: post)
                .task { try? await model.loadMorePosts(after: post) }
                .id(post.id)
        }
    }

    @ViewBuilder
    private var loadingPagePlaceholder: some View {
        if model.isLoading && model.didReachEnd {
            ForEach(0..<100) { _ in
                PlaceholderPostView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhotoCollectionView()
    }
    .environment(\.postLoader, try! PostLoader(
        frontTags: ["9327ded7-eb63-468a-95e5-9500f5081df1"],
        backTags: ["54392ce6-c1b2-48ea-a384-c6b113413bf3"],
    ))
    .colorScheme(.dark)
}

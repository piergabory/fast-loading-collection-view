import ImmichAPI
import SwiftUI

struct PhotoCollectionView: View {
    static let spacing: CGFloat = 2

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: spacing),
        count: 4,
    )

    @Environment(\.postLoader)
    private var model: PostLoader

    @State
    private var errorMessage: String?

    var body: some View {
        ScrollViewReader { proxy in
            collectionView
                .toolbar {
                    Button(
                        "Jump to the top",
                        systemImage:  "arrow.up.to.line"
                    ) {
                        proxy.scrollTo("Top")
                    }
                    Button(
                        "Jump to the top",
                        systemImage:  "arrow.down.to.line"
                    ) {
                        proxy.scrollTo("Bottom")
                    }
                }
        }
        .task {
            try? await model.preload()
        }
    }

    private var collectionView: some View {
        ScrollView {
            Text("That's all folks!")
                .padding()
                .id("Top")
            LazyVGrid(columns: columns, spacing: Self.spacing) {
                postThumbnails
                loadingPagePlaceholder
            }
            Label(
                "Scroll up to turn back time", 
                systemImage: "clock.arrow.circlepath"
            )
            .padding()
            .id("Bottom")
        }
        .defaultScrollAnchor(.bottom)
        .scrollEdgeEffectStyle(.soft, for: .all)
        .background()
    }

    private var postThumbnails: some View {
        ForEach(model.posts.reversed()) { post in
            ThumbnailView(post: post)
                .task { try? await model.loadMorePosts(after: post) }
                .onAppear { preloadIfNeeded(on: post) }
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


    // TODO: Move this away

    @Environment(\.postStore)
    private var postStore: PostStore

    private static var isPreloading: Bool = false

    private func preloadIfNeeded(on post: Post) {
        if model.didReachEnd || Self.isPreloading { return }

        let postCount = model.posts.count
        let postIndex = model.posts.firstIndex { $0.id == post.id }
        guard let postIndex, postIndex > postCount - 200 else { return }

        Task {
            Self.isPreloading = true
            print("Reaching the last page, warming up cache...")

            // !!!
            // If a view is using a custom environment PostStore value
            // It will not benefit!
            // This is just a hack to test the idea.
            // This all does not belong here at all
            let service = CacheWarmupService(postLoader: model, postStore: postStore)
            do {
                try await service.preloadCache(max: postCount + 500)
            } catch {
                print("Cache warmup failed (\(error)).")
            }
            Self.isPreloading = false
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

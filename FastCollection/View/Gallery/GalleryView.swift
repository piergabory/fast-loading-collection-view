import ImmichAPI
import SwiftUI

struct GalleryView: View {
    @Bindable
    var model: GalleryViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollingGrid(items: model.posts) { post in
                ThumbnailView(post)
                    .onAppear {
                        model.loadMore(after: post)
                    }
            } header: {
                header
            } footer: {
                footer
            }
            .toolbar {
                jumpButtons(proxy)
            }
        }
        .task {
            await model.start()
        }
    }

    private var header: some View {
        Text("That's all folks!")
            .padding()
            .id("Top")
    }

    private var footer: some View {
        Label(
            "Scroll up to turn back time",
            systemImage: "clock.arrow.circlepath",
        )
        .padding()
        .id("Bottom")
    }

    @ViewBuilder
    private func jumpButtons(_ proxy: ScrollViewProxy) -> some View {
        Button(
            "Jump to the top",
            systemImage: "arrow.up.to.line",
        ) {
            proxy.scrollTo("Top")
        }
        Button(
            "Jump to the top",
            systemImage: "arrow.down.to.line",
        ) {
            proxy.scrollTo("Bottom")
        }
    }
}

#Preview {
    NavigationStack {
        GalleryView(
            model: GalleryViewModel(
                metadataLoader: try! PostMetadataLoader(
                    frontTags: ["9327ded7-eb63-468a-95e5-9500f5081df1"],
                    backTags: ["54392ce6-c1b2-48ea-a384-c6b113413bf3"],
                )
            )
        )
    }
    .colorScheme(.dark)
}

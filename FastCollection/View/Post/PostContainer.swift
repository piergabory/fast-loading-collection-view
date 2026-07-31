import SwiftUI

struct PostContainer<Content: View>: View {
    @ViewBuilder
    let content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(3/4, contentMode: .fill)
            .background(.background.secondary)
            .clipped()
    }
}

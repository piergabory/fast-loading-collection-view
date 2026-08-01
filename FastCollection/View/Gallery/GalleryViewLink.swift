import SwiftUI

struct GalleryViewLink: View {
    let model: GalleryViewModel

    var body: some View {
        NavigationLink {
            GalleryView(model: model)
        } label: {
            Text("Open Gallery")
                .bold()
                .frame(height: 32)
        }
        .buttonStyle(.borderedProminent)
        .buttonSizing(.flexible)
        .padding()
    }
}

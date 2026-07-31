import SwiftUI

struct GoToPhotosButton: View {
    var body: some View {
        NavigationLink {
            PhotoCollectionView()
        } label: {
            Text("Photos")
                .bold()
                .frame(height: 32)
        }
        .buttonStyle(.borderedProminent)
        .buttonSizing(.flexible)
        .padding()
    }
}

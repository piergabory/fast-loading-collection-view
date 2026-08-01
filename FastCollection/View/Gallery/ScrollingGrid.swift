import SwiftUI

struct ScrollingGrid<
    Item: Identifiable,
    Cell: View,
    Header: View,
    Footer: View
>: View {
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 2),
        count: 4,
    )

    let items: [Item]

    @ViewBuilder
    let cell: (Item) -> Cell

    @ViewBuilder
    let header: Header

    @ViewBuilder
    let footer: Footer

    var body: some View {
        ScrollView {
            header
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(items) { item in
                    cell(item)
                }
            }
            footer
        }
        .defaultScrollAnchor(.bottom)
        .scrollEdgeEffectStyle(.soft, for: .all)
        .background()
    }
}

import SwiftUI

struct ConnectionStatus: Equatable {
    let title: String
    let color: Color
    let image: Image

    static let connecting = ConnectionStatus(
        title: "Connecting",
        color: .secondary,
        image: Image(systemName: "ellipsis"),
    )

    static let connected = ConnectionStatus(
        title: "Connected",
        color: .green,
        image: Image(systemName: "checkmark"),
    )

    static let failed = ConnectionStatus(
        title: "Connection failed",
        color: .red,
        image: Image(systemName: "xmark"),
    )

    static let disconnected = ConnectionStatus(
        title: "Disconnected",
        color: .secondary,
        image: Image(systemName: "questionmark")
    )
}



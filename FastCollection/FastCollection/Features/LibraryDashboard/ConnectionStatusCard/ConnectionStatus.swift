import SwiftUI

struct ConnectionStatus: Equatable {
    let title: String
    let detail: String
    let color: Color
    let image: Image

    static let connecting = ConnectionStatus(
        title: "Connecting",
        detail: "Checking the Immich server",
        color: .secondary,
        image: Image(systemName: "ellipsis"),
    )

    static let connected = ConnectionStatus(
        title: "Connected",
        detail: "Server and API key are available",
        color: .green,
        image: Image(systemName: "checkmark"),
    )

    static let failed = ConnectionStatus(
        title: "Connection failed",
        detail: "Could not load the Immich library",
        color: .red,
        image: Image(systemName: "xmark"),
    )

    static let disconnected = ConnectionStatus(
        title: "Disconnected",
        detail: "No attempts at reaching the serve have been done",
        color: .secondary,
        image: Image(systemName: "questionmark")
    )
}



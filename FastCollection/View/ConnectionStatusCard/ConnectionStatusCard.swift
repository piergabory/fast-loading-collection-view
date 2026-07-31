import SwiftUI

struct ConnectionStatusCard: View {
    let status: ConnectionStatus

    var body: some View {
        Label {
            Text(status.title)
        } icon: {
            if status == .connecting {
                ProgressView()
            } else {
                status.image
            }
        }
    }
}

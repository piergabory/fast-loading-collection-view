import SwiftUI

struct ConnectionStatusCard: View {
    let status: ConnectionStatus

    var body: some View {
        HStack {
            ZStack {
                if status == .connecting {
                    ProgressView()
                } else {
                    status.image
                }
            }
            .font(.title3.bold())
            .foregroundStyle(status.color)
            .frame(width: 48, height: 48)
            .background(status.color.opacity(0.14), in: Circle())

            VStack(alignment: .leading) {
                Text(status.title)
                    .font(.headline)
                Text(status.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

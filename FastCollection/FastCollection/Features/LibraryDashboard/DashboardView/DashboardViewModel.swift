import Foundation
import Immich
import ImmichAPI
import Observation

@Observable @MainActor
final class DashboardViewModel {
    var status: ConnectionStatus = .disconnected
    var errorMessage: String?
    var frontTags: [Tag.ID] = []
    var backTags: [Tag.ID] = []

    func reload() async {
        status = .connecting
        do {
            let tags = try await Request.tags()
            process(tags)
            status = .connected
        } catch {
            errorMessage = error.localizedDescription
            status = .failed
        }
    }

    private func process(_ tags: [Tag]) {
        frontTags = tags
            .filter { $0.value == "BeReal/front" }
            .map { $0.id }
        backTags = tags
            .filter { $0.value == "BeReal/back" }
            .map { $0.id }
    }
}

import Foundation
import Immich
import ImmichAPI
import Observation

@Observable @MainActor
final class DashboardViewModel {
    var status: ConnectionStatus = .disconnected
    var errorMessage: String?
    var postLoader = try! PostLoader(frontTags: [], backTags: [])

    func reload() async {
        status = .connecting
        do {
            let tags = try await Request.tags()
            try process(tags)
            status = .connected
        } catch {
            errorMessage = error.localizedDescription
            status = .failed
        }
    }

    private func process(_ tags: [Tag]) throws {
        let frontTags = tags
            .filter { $0.value == "BeReal/front" }
            .map { $0.id }
        let backTags = tags
            .filter { $0.value == "BeReal/back" }
            .map { $0.id }

        postLoader = try PostLoader(frontTags: frontTags, backTags: backTags)
    }
}

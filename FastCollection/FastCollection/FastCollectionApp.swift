import Immich
import SwiftUI

@main
struct FastCollectionApp: App {
    init() {
        unsafe Immich.apiSecrets = ImmichSecrets()
    }

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .colorScheme(.dark)
        }
    }
}

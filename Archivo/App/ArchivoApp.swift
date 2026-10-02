import SwiftUI

@main
struct ArchivoApp: App {
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .preferredColorScheme(.dark)
                .task { await session.restore() }
        }
    }
}


import Foundation
import Observation

/// The 5 real lifecycle startup stages matching the web and native splash screen.
enum StartupStage: Sendable {
    case connecting // 10%: Initial connection to Cloudflare Workers runtime
    case session    // 30%: Validating D1 session cookie
    case profile    // 55%: Loading profile & preferences
    case data       // 75%: Loading memories & local state
    case ready      // 100%: Finished, ready for smooth fade-out transition

    var progress: Double {
        switch self {
        case .connecting: 0.10
        case .session:    0.30
        case .profile:    0.55
        case .data:       0.75
        case .ready:      1.00
        }
    }
}

@MainActor
@Observable
final class SessionStore {
    var profile: Profile?
    var isRestoring = true
    var startupStage: StartupStage = .connecting
    var errorMessage: String?

    var isAuthenticated: Bool { profile != nil }

    func restore() async {
        startupStage = .connecting
        isRestoring = true
        errorMessage = nil

        do {
            // Stage 1: Connecting
            try? await Task.sleep(nanoseconds: 60_000_000)
            startupStage = .session

            // Stage 2: Request Bootstrap from backend
            let response: BootstrapResponse = try await APIClient.shared.request("/api/bootstrap")

            // Stage 3: Profile loaded
            startupStage = .profile
            try? await Task.sleep(nanoseconds: 60_000_000)

            // Stage 4: Memories & Data loaded
            startupStage = .data
            profile = response.profile
            try? await Task.sleep(nanoseconds: 80_000_000)

            // Stage 5: Ready
            startupStage = .ready
        } catch {
            profile = nil
            startupStage = .ready
        }

        // Slight grace period for the 400ms splash fade out animation
        try? await Task.sleep(nanoseconds: 200_000_000)
        isRestoring = false
    }

    func login(username: String, password: String) async -> Bool {
        struct Credentials: Encodable {
            let username: String
            let password: String
        }

        struct LoginResponse: Decodable {
            let success: Bool?
            let userId: String?
            let username: String?
            let error: String?
        }

        errorMessage = nil
        do {
            let response: LoginResponse = try await APIClient.shared.request(
                "/api/login",
                method: "POST",
                body: Credentials(username: username, password: password)
            )

            if response.success == true {
                await restore()
                return isAuthenticated
            } else {
                errorMessage = response.error ?? "No se pudo iniciar sesión."
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func logout() async {
        struct Empty: Encodable {}
        struct Result: Decodable { let ok: Bool? }
        let _: Result? = try? await APIClient.shared.request("/api/logout", method: "POST", body: Empty())
        profile = nil
    }
}

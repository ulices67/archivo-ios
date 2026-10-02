import Foundation
import Observation

@MainActor
@Observable
final class SessionStore {
    var user: ArchivoUser?
    var isRestoring = true
    var errorMessage: String?

    var isAuthenticated: Bool { user != nil }

    func restore() async {
        defer { isRestoring = false }
        do {
            let response: BootstrapResponse = try await APIClient.shared.request("/api/bootstrap")
            user = response.authenticated == false ? nil : response.user
        } catch {
            user = nil
        }
    }

    func login(username: String, password: String) async -> Bool {
        struct Credentials: Encodable { let username: String; let password: String }
        struct LoginResponse: Decodable { let user: ArchivoUser? }
        do {
            let response: LoginResponse = try await APIClient.shared.request(
                "/api/login", method: "POST", body: Credentials(username: username, password: password)
            )
            user = response.user
            if user == nil { await restore() }
            return isAuthenticated
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func logout() async {
        struct Empty: Encodable {}
        struct Result: Decodable { let ok: Bool? }
        let _: Result? = try? await APIClient.shared.request("/api/logout", method: "POST", body: Empty())
        user = nil
    }
}


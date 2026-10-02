import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case server(Int, String)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "La respuesta del servidor no es válida."
        case let .server(_, message): message
        case let .decoding(error): "No se pudo interpretar la respuesta: \(error.localizedDescription)"
        }
    }
}

actor APIClient {
    static let shared = APIClient()
    static let baseURL = URL(string: "https://archivo.societext.workers.dev")!

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    func request<Response: Decodable>(
        _ path: String,
        method: String = "GET",
        body: (any Encodable)? = nil
    ) async throws -> Response {
        var request = URLRequest(url: Self.baseURL.appending(path: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? JSONDecoder().decode(ServerMessage.self, from: data).message)
                ?? String(data: data, encoding: .utf8)
                ?? "Error del servidor"
            throw APIError.server(http.statusCode, message)
        }
        do { return try decoder.decode(Response.self, from: data) }
        catch { throw APIError.decoding(error) }
    }
}

private struct ServerMessage: Decodable { let message: String? }

private struct AnyEncodable: Encodable {
    private let encodeValue: (Encoder) throws -> Void
    init(_ value: any Encodable) { encodeValue = { try value.encode(to: $0) } }
    func encode(to encoder: Encoder) throws { try encodeValue(encoder) }
}


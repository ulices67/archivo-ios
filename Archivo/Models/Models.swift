import Foundation

struct BootstrapResponse: Decodable, Sendable {
    let authenticated: Bool?
    let user: ArchivoUser?
    let memories: [Memory]?
    let notifications: [ArchivoNotification]?
}

struct ArchivoUser: Codable, Identifiable, Sendable {
    let id: Int64?
    let username: String
    let displayName: String?
    let bio: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, username, bio
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
    }
}

struct Memory: Codable, Identifiable, Sendable {
    let id: Int64
    let title: String
    let description: String?
    let visibility: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, visibility
        case createdAt = "created_at"
    }
}

struct SocialPost: Codable, Identifiable, Sendable {
    let id: Int64
    let kind: String?
    let title: String?
    let body: String?
    let mediaUrl: String?
    let visibility: String?
    let username: String?
    let displayName: String?

    enum CodingKeys: String, CodingKey {
        case id, kind, title, body, visibility, username
        case mediaUrl = "media_url"
        case displayName = "display_name"
    }
}

struct Conversation: Codable, Identifiable, Sendable {
    let id: Int64
    let username: String?
    let displayName: String?
    let lastMessage: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id, username, status
        case displayName = "display_name"
        case lastMessage = "last_message"
    }
}

struct ArchivoNotification: Codable, Identifiable, Sendable {
    let id: Int64
    let title: String
    let body: String?
    let readAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, body
        case readAt = "read_at"
    }
}


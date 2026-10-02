import Foundation

// MARK: - Bootstrap Response

struct BootstrapResponse: Codable, Sendable {
    let profile: Profile?
    let memories: [Memory]?
    let collaborationInvites: [CollaborationInvite]?
    let socialStats: SocialStats?

    enum CodingKeys: String, CodingKey {
        case profile, memories
        case collaborationInvites = "collaborationInvites"
        case socialStats = "socialStats"
    }
}

// MARK: - User Profile

struct Profile: Codable, Identifiable, Sendable {
    var id: String { userId }
    let userId: String
    let username: String
    let email: String?
    let displayName: String?
    let bio: String?
    let avatarUrl: String?
    let profileMode: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username, email, bio
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case profileMode = "profile_mode"
    }

    var effectiveDisplayName: String {
        if let displayName, !displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            return displayName
        }
        return username
    }
}

// MARK: - Memory

struct Memory: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let description: String?
    let visibility: String?
    let symbol: String?
    let startDate: String?
    let endDate: String?
    let datePrecision: String?
    let isFavorite: Int?
    let isArchived: Int?
    let createdAt: String?
    let updatedAt: String?
    let entryCount: Int?
    let ownerName: String?
    let ownerUsername: String?
    let isOwner: Int?
    let collaboratorCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, description, visibility, symbol
        case startDate = "start_date"
        case endDate = "end_date"
        case datePrecision = "date_precision"
        case isFavorite = "is_favorite"
        case isArchived = "is_archived"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case entryCount = "entry_count"
        case ownerName = "owner_name"
        case ownerUsername = "owner_username"
        case isOwner = "is_owner"
        case collaboratorCount = "collaborator_count"
    }

    var displaySymbol: String { symbol ?? "○" }
    var effectiveVisibility: String { visibility ?? "private" }
    var totalEntries: Int { entryCount ?? 0 }
}

// MARK: - Memory Entry

struct MemoryEntry: Codable, Identifiable, Sendable {
    let id: String
    let memoryId: String
    let userId: String
    let entryType: String
    let title: String?
    let description: String?
    let eventDate: String?
    let mediaUrl: String?
    let visibility: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, visibility
        case memoryId = "memory_id"
        case userId = "user_id"
        case entryType = "entry_type"
        case eventDate = "event_date"
        case mediaUrl = "media_url"
        case createdAt = "created_at"
    }
}

// MARK: - Social Post

struct SocialPost: Codable, Identifiable, Sendable {
    let id: String
    let kind: String?
    let title: String?
    let body: String?
    let mediaUrl: String?
    let visibility: String?
    let username: String?
    let displayName: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, kind, title, body, visibility, username
        case mediaUrl = "media_url"
        case displayName = "display_name"
        case createdAt = "created_at"
    }

    var effectiveAuthor: String {
        if let displayName, !displayName.isEmpty { return displayName }
        return username ?? "Archivo"
    }
}

// MARK: - Social Stats

struct SocialStats: Codable, Sendable {
    let followers: Int?
    let following: Int?
    let friends: Int?
}

// MARK: - Collaboration Invite

struct CollaborationInvite: Codable, Identifiable, Sendable {
    let id: String
    let memoryId: String
    let memoryTitle: String?
    let memorySymbol: String?
    let personName: String?
    let personUsername: String?
    let avatarUrl: String?
    let role: String?
    let message: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, role, message
        case memoryId = "memory_id"
        case memoryTitle = "memory_title"
        case memorySymbol = "memory_symbol"
        case personName = "person_name"
        case personUsername = "person_username"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}

// MARK: - Notification

struct ArchivoNotification: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let body: String?
    let readAt: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, body
        case readAt = "read_at"
        case createdAt = "created_at"
    }

    var isRead: Bool { readAt != nil }
}

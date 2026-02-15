import Foundation

/// Represents a project that groups multiple sessions
struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var sessionIds: [UUID]
    var colorHex: String?
    var createdAt: Date
    var isExpanded: Bool

    init(
        id: UUID = UUID(),
        name: String,
        sessionIds: [UUID] = [],
        colorHex: String? = nil,
        createdAt: Date = Date(),
        isExpanded: Bool = true
    ) {
        self.id = id
        self.name = name
        self.sessionIds = sessionIds
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.isExpanded = isExpanded
    }

    var sessionCount: Int {
        sessionIds.count
    }

    mutating func addSession(_ sessionId: UUID) {
        if !sessionIds.contains(sessionId) {
            sessionIds.append(sessionId)
        }
    }

    mutating func removeSession(_ sessionId: UUID) {
        sessionIds.removeAll { $0 == sessionId }
    }

    mutating func toggleExpanded() {
        isExpanded.toggle()
    }
}

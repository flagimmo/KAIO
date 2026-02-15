import Foundation

/// Represents a terminal session with command history
struct Session: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var workingDirectory: String
    var history: [Command]
    var createdAt: Date
    var lastAccessedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        workingDirectory: String = FileManager.default.currentDirectoryPath,
        history: [Command] = [],
        createdAt: Date = Date(),
        lastAccessedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.workingDirectory = workingDirectory
        self.history = history
        self.createdAt = createdAt
        self.lastAccessedAt = lastAccessedAt
    }

    var lastCommand: Command? {
        history.last
    }

    var commandCount: Int {
        history.count
    }

    mutating func addCommand(_ command: Command) {
        history.append(command)
        lastAccessedAt = Date()
    }

    mutating func clearHistory() {
        history.removeAll()
    }
}

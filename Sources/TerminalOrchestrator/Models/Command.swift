import Foundation

/// Represents a single command execution in a session
struct Command: Identifiable, Codable, Equatable {
    let id: UUID
    let command: String
    let output: String
    let timestamp: Date
    let exitCode: Int

    init(
        id: UUID = UUID(),
        command: String,
        output: String = "",
        timestamp: Date = Date(),
        exitCode: Int = 0
    ) {
        self.id = id
        self.command = command
        self.output = output
        self.timestamp = timestamp
        self.exitCode = exitCode
    }

    var isSuccess: Bool {
        exitCode == 0
    }
}

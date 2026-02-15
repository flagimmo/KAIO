import Foundation

/// Represents a CLI tool configuration (Claude Code, Gemini CLI, etc.)
public struct CLITool: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let command: String
    public let arguments: [String]
    public let workingDirectory: String?
    public let environmentVariables: [String: String]

    public init(
        id: UUID = UUID(),
        name: String,
        command: String,
        arguments: [String] = [],
        workingDirectory: String? = nil,
        environmentVariables: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.command = command
        self.arguments = arguments
        self.workingDirectory = workingDirectory
        self.environmentVariables = environmentVariables
    }

    /// Predefined CLI tools
    public static let presets: [CLITool] = [
        CLITool(
            name: "Claude Code",
            command: "claude",
            arguments: ["code"]
        ),
        CLITool(
            name: "Gemini CLI",
            command: "gemini",
            arguments: []
        ),
        CLITool(
            name: "GitHub Copilot CLI",
            command: "gh",
            arguments: ["copilot"]
        ),
        CLITool(
            name: "OpenAI Codex CLI",
            command: "codex",
            arguments: []
        ),
        CLITool(
            name: "Custom Shell",
            command: "/bin/bash",
            arguments: ["-l"]
        )
    ]
}

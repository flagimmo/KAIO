import Foundation

/// Represents a terminal session running a CLI tool
class Session: Identifiable, ObservableObject {
    let id: UUID
    let tool: CLITool
    @Published var status: SessionStatus
    @Published var output: [OutputLine]
    @Published var startTime: Date?

    var process: Process?

    init(
        id: UUID = UUID(),
        tool: CLITool,
        status: SessionStatus = .idle
    ) {
        self.id = id
        self.tool = tool
        self.status = status
        self.output = []
        self.startTime = nil
    }

    func addOutput(_ text: String, type: OutputType = .stdout) {
        let line = OutputLine(
            id: UUID(),
            text: text,
            type: type,
            timestamp: Date()
        )
        output.append(line)
    }

    var displayName: String {
        tool.name
    }

    var statusIcon: String {
        switch status {
        case .idle: return "⚪️"
        case .running: return "🟢"
        case .stopped: return "🔴"
        case .error: return "⚠️"
        }
    }
}

/// Session status
enum SessionStatus: String, Codable {
    case idle = "Idle"
    case running = "Running"
    case stopped = "Stopped"
    case error = "Error"
}

/// Output line type
enum OutputType: String, Codable {
    case stdout
    case stderr
    case system
}

/// Individual output line
struct OutputLine: Identifiable {
    let id: UUID
    let text: String
    let type: OutputType
    let timestamp: Date
}

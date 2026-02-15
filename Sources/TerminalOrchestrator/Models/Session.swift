import Foundation

/// Represents a terminal session running a CLI tool
class Session: Identifiable, ObservableObject {

    // MARK: - Properties

    let id: UUID
    let tool: CLITool

    @Published var status: SessionStatus
    @Published var output: [OutputLine]
    @Published var startTime: Date?

    var process: Process?

    // MARK: - Initialization

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

    // MARK: - Public Methods

    func addOutput(_ text: String, type: OutputType = .stdout) {
        output.append(OutputLine(text: text, type: type))
    }

    func clearOutput() {
        output.removeAll()
    }

    // MARK: - Computed Properties

    var displayName: String {
        tool.name
    }

    var statusIcon: String {
        status.icon
    }

    var isRunning: Bool {
        status == .running
    }
}

// MARK: - Session Status

/// Session status
enum SessionStatus: String, Codable {
    case idle = "Idle"
    case running = "Running"
    case stopped = "Stopped"
    case error = "Error"

    var icon: String {
        switch self {
        case .idle: return "⚪️"
        case .running: return "🟢"
        case .stopped: return "🔴"
        case .error: return "⚠️"
        }
    }
}

// MARK: - Output Type

/// Output line type
enum OutputType: String, Codable {
    case stdout
    case stderr
    case system
}

// MARK: - Output Line

/// Individual output line
struct OutputLine: Identifiable {
    let id: UUID
    let text: String
    let type: OutputType
    let timestamp: Date

    init(
        id: UUID = UUID(),
        text: String,
        type: OutputType,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.type = type
        self.timestamp = timestamp
    }

    var formattedTime: String {
        Self.timeFormatter.string(from: timestamp)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

import Foundation

/// Represents a terminal session running a CLI tool
public class Session: Identifiable, ObservableObject {

    // MARK: - Properties

    public let id: UUID
    public let tool: CLITool

    @Published public var status: SessionStatus
    @Published public var output: [OutputLine]
    @Published public var startTime: Date?

    public var process: Process?

    // MARK: - Initialization

    public init(
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

    public func addOutput(_ text: String, type: OutputType = .stdout) {
        output.append(OutputLine(text: text, type: type))
    }

    public func clearOutput() {
        output.removeAll()
    }

    // MARK: - Computed Properties

    public var displayName: String {
        tool.name
    }

    public var statusIcon: String {
        status.icon
    }

    public var isRunning: Bool {
        status == .running
    }
}

// MARK: - Session Status

/// Session status
public enum SessionStatus: String, Codable {
    case idle = "Idle"
    case running = "Running"
    case stopped = "Stopped"
    case error = "Error"

    public var icon: String {
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
public enum OutputType: String, Codable {
    case stdout
    case stderr
    case system
}

// MARK: - Output Line

/// Individual output line
public struct OutputLine: Identifiable {
    public let id: UUID
    public let text: String
    public let type: OutputType
    public let timestamp: Date

    public init(
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

    public var formattedTime: String {
        Self.timeFormatter.string(from: timestamp)
    }

    public static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

import SwiftCrossUI

// MARK: - App State

/// Global application state
public class AppState: ObservableObject {

    // MARK: - Published Properties

    @Published public var sessions: [Session] = []
    @Published public var selectedSession: Session?

    // MARK: - Initialization

    public init(createDemoSession: Bool = true) {
        if createDemoSession {
            setupDemoSession()
        }
    }

    // MARK: - Public Methods

    /// Create a new session from a tool preset
    public func createNewSession(tool: CLITool? = nil) {
        let selectedTool = tool ?? defaultTool
        let newSession = Session(tool: selectedTool)

        sessions.append(newSession)
        selectedSession = newSession
    }

    /// Delete a session
    public func deleteSession(_ session: Session) {
        terminateSessionProcess(session)
        removeSession(session)
        updateSelectionAfterDeletion(session)
    }

    // MARK: - Private Methods

    private func setupDemoSession() {
        let demoTool = CLITool(
            name: "Demo: Echo Server",
            command: "bash",
            arguments: ["-c", "while true; do echo 'Server running...'; sleep 2; done"]
        )
        let demoSession = Session(tool: demoTool)

        sessions.append(demoSession)
        selectedSession = demoSession
    }

    private func terminateSessionProcess(_ session: Session) {
        guard let process = session.process, process.isRunning else { return }
        process.terminate()
    }

    private func removeSession(_ session: Session) {
        sessions.removeAll { $0.id == session.id }
    }

    private func updateSelectionAfterDeletion(_ deletedSession: Session) {
        if selectedSession?.id == deletedSession.id {
            selectedSession = sessions.first
        }
    }

    private var defaultTool: CLITool {
        CLITool.presets.first ?? CLITool(
            name: "Custom Command",
            command: "bash",
            arguments: ["-l"]
        )
    }
}

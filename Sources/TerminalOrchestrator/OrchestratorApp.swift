import SwiftCrossUI

// MARK: - App State

/// Global application state
class AppState: ObservableObject {

    // MARK: - Published Properties

    @Published var sessions: [Session] = []
    @Published var selectedSession: Session?

    // MARK: - Initialization

    init(createDemoSession: Bool = true) {
        if createDemoSession {
            setupDemoSession()
        }
    }

    // MARK: - Public Methods

    /// Create a new session from a tool preset
    func createNewSession(tool: CLITool? = nil) {
        let selectedTool = tool ?? defaultTool
        let newSession = Session(tool: selectedTool)

        sessions.append(newSession)
        selectedSession = newSession
    }

    /// Delete a session
    func deleteSession(_ session: Session) {
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

// MARK: - Main App

/// Main application definition
@main
struct OrchestratorApp: App {

    // MARK: - State

    @StateObject private var appState = AppState()
    @StateObject private var processManager = ProcessManager()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup("Terminal Orchestrator") {
            MainView(
                appState: appState,
                processManager: processManager
            )
            .frame(
                minWidth: Theme.Sizes.minWindowWidth,
                minHeight: Theme.Sizes.minWindowHeight
            )
        }
    }
}

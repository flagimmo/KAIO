import SwiftCrossUI

/// Global application state
class AppState: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var selectedSession: Session?

    init() {
        // Create a demo session on startup
        let demoTool = CLITool(
            name: "Demo: Echo Server",
            command: "bash",
            arguments: ["-c", "while true; do echo 'Server running...'; sleep 2; done"]
        )
        let demoSession = Session(tool: demoTool, status: .idle)
        sessions.append(demoSession)
        selectedSession = demoSession
    }

    /// Create a new session from a tool preset
    func createNewSession(tool: CLITool? = nil) {
        let selectedTool = tool ?? CLITool.presets.first ?? CLITool(
            name: "Custom Command",
            command: "bash",
            arguments: ["-l"]
        )

        let newSession = Session(tool: selectedTool)
        sessions.append(newSession)
        selectedSession = newSession
    }

    /// Delete a session
    func deleteSession(_ session: Session) {
        // Stop the process if running
        if let process = session.process, process.isRunning {
            process.terminate()
        }

        // Remove from list
        sessions.removeAll { $0.id == session.id }

        // Update selection
        if selectedSession?.id == session.id {
            selectedSession = sessions.first
        }
    }

    /// Create a session from a preset tool
    func createSessionFromPreset(_ preset: CLITool) {
        createNewSession(tool: preset)
    }
}

/// Main application definition
@main
struct OrchestratorApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var processManager = ProcessManager()

    var body: some Scene {
        WindowGroup("Terminal Orchestrator") {
            MainView(
                appState: appState,
                processManager: processManager
            )
            .frame(minWidth: 800, minHeight: 600)
        }
    }
}

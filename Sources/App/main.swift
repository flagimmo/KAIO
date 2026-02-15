import SwiftCrossUI
import TerminalOrchestratorCore

// MARK: - Main App

/// Main application definition
@main
struct OrchestratorApp: App {

    // MARK: - State

    @State private var sessionManager = SessionManager()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup("Terminal Orchestrator") {
            MainView()
                .environment(sessionManager)
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}

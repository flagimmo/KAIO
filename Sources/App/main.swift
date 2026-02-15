import SwiftCrossUI
import TerminalOrchestratorCore

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

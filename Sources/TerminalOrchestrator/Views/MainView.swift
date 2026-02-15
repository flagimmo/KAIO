import SwiftCrossUI

/// Main view containing the session list and detail view
struct MainView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var processManager: ProcessManager

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar with session list
            SessionListView(
                sessions: $appState.sessions,
                selectedSession: $appState.selectedSession,
                onNewSession: {
                    appState.createNewSession()
                },
                onDeleteSession: { session in
                    appState.deleteSession(session)
                }
            )

            // Divider
            Divider()

            // Main content area
            if let selectedSession = appState.selectedSession {
                SessionDetailView(
                    session: selectedSession,
                    processManager: processManager
                )
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Text("No session selected")
                        .fontSize(18)
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 1.0))

                    Text("Create a new session or select an existing one")
                        .fontSize(14)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0))
                }
                .frame(minWidth: 400, minHeight: 300)
            }
        }
    }
}

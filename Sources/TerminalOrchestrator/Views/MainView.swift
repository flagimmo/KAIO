import SwiftCrossUI

/// Main view containing the session list and detail view
struct MainView: View {

    // MARK: - Properties

    @ObservedObject var appState: AppState
    @ObservedObject var processManager: ProcessManager

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            contentArea
        }
    }

    // MARK: - View Components

    private var sidebar: some View {
        SessionListView(
            sessions: $appState.sessions,
            selectedSession: $appState.selectedSession,
            onNewSession: { appState.createNewSession() },
            onDeleteSession: { appState.deleteSession($0) }
        )
    }

    private var contentArea: some View {
        Group {
            if let selectedSession = appState.selectedSession {
                SessionDetailView(
                    session: selectedSession,
                    processManager: processManager
                )
            } else {
                emptyState
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.extraLarge) {
            Text("No session selected")
                .fontSize(Theme.FontSizes.header)
                .foregroundColor(Theme.Colors.emptyStateText)

            Text("Create a new session or select an existing one")
                .fontSize(Theme.FontSizes.body)
                .foregroundColor(Theme.Colors.emptyStateSubtext)
        }
        .frame(minWidth: Theme.Sizes.minContentWidth, minHeight: Theme.Sizes.minContentHeight)
    }
}

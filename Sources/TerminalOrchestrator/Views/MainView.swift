import SwiftCrossUI

/// Main view containing the session list and detail view
struct MainView: View {

    // MARK: - Properties

    @ObservedObject var appState: AppState
    @ObservedObject var processManager: ProcessManager

    // Resizable sidebar state
    @State private var sidebarWidth: Double = Theme.Sizes.sidebarWidth
    @State private var isDragging: Bool = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            resizableDivider
            contentArea
        }
    }

    // MARK: - View Components

    private var sidebar: some View {
        SessionListView(
            sessions: $appState.sessions,
            selectedSession: $appState.selectedSession,
            onNewSession: { appState.createNewSession() },
            onDeleteSession: { appState.deleteSession($0) },
            width: sidebarWidth
        )
    }

    private var resizableDivider: some View {
        Rectangle()
            .fill(isDragging ? Color(red: 0.3, green: 0.5, blue: 0.8, opacity: 1.0) : Color(red: 0.3, green: 0.3, blue: 0.3, opacity: 1.0))
            .frame(width: isDragging ? 3 : 1)
            .onHover { isHovering in
                // Visual feedback on hover (cursor would change in native app)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let newWidth = sidebarWidth + value.translation.width
                        // Constrain sidebar width between min and max
                        sidebarWidth = min(max(newWidth, Theme.Sizes.sidebarMinWidth), Theme.Sizes.sidebarMaxWidth)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
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

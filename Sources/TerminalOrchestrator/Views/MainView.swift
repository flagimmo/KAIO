import SwiftCrossUI

/// Main view containing the session list and detail view
struct MainView: View {

    // MARK: - Properties

    @ObservedObject var appState: AppState
    @ObservedObject var processManager: ProcessManager

    // Resizable sidebar state
    @State private var sidebarWidth: Double = UserDefaults.standard.sidebarWidth
    @State private var isDragging: Bool = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            resizableDivider
            contentArea
        }
        .onAppear {
            // Load saved sidebar width on app start
            loadSidebarWidth()
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
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                        }

                        // Edge case: Clamp drag offset to prevent extreme jumps
                        let maxDragPerFrame = 50.0
                        let clampedOffset = min(
                            max(value.translation.width, -maxDragPerFrame),
                            maxDragPerFrame
                        )

                        let newWidth = sidebarWidth + clampedOffset

                        // Edge case: Constrain sidebar width between min and max
                        let constrainedWidth = min(
                            max(newWidth, Theme.Sizes.sidebarMinWidth),
                            Theme.Sizes.sidebarMaxWidth
                        )

                        // Edge case: Validate before assigning
                        if constrainedWidth.isFinite && constrainedWidth > 0 {
                            sidebarWidth = constrainedWidth
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        // Save sidebar width to UserDefaults
                        saveSidebarWidth()
                    }
            )
    }

    // MARK: - Private Methods

    private func loadSidebarWidth() {
        // Load from UserDefaults (already initialized in @State)
        let storedWidth = UserDefaults.standard.sidebarWidth

        // Edge case: Validate loaded width
        guard storedWidth > 0,
              storedWidth.isFinite,
              storedWidth >= Theme.Sizes.sidebarMinWidth,
              storedWidth <= Theme.Sizes.sidebarMaxWidth else {
            // Invalid stored value - use default
            sidebarWidth = Theme.Sizes.sidebarWidth
            return
        }

        sidebarWidth = storedWidth
    }

    private func saveSidebarWidth() {
        // Edge case: Only save if value is valid
        guard sidebarWidth > 0,
              sidebarWidth.isFinite,
              sidebarWidth >= Theme.Sizes.sidebarMinWidth,
              sidebarWidth <= Theme.Sizes.sidebarMaxWidth else {
            return
        }

        // Save to UserDefaults when drag ends
        UserDefaults.standard.sidebarWidth = sidebarWidth
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

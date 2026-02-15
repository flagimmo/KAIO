import SwiftCrossUI

/// Main view with session manager and project organization
struct MainView: View {

    // MARK: - Properties

    @Environment(SessionManager.self) private var sessionManager

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            divider
            contentArea
        }
    }

    // MARK: - View Components

    private var sidebar: some View {
        SidebarView()
            .frame(minWidth: 250, maxWidth: 300)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 1)
    }

    private var contentArea: some View {
        Group {
            if let activeSessionId = sessionManager.activeSessionId {
                SessionDetailView(sessionId: activeSessionId)
            } else {
                emptyState
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("No session selected")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Create a new session or select an existing one from the sidebar")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

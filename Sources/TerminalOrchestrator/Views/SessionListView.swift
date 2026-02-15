import SwiftCrossUI

/// Displays the list of terminal sessions in a sidebar
struct SessionListView: View {

    // MARK: - Properties

    @Binding var sessions: [Session]
    @Binding var selectedSession: Session?
    let onNewSession: () -> Void
    let onDeleteSession: (Session) -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            header
            sessionList
            newSessionButton
        }
        .padding(Theme.Spacing.large)
        .frame(width: Theme.Sizes.sidebarWidth)
    }

    // MARK: - View Components

    private var header: some View {
        Text("Sessions")
            .fontSize(Theme.FontSizes.subheader)
            .bold()
    }

    private var sessionList: some View {
        ForEach(sessions) { session in
            SessionRowView(
                session: session,
                isSelected: selectedSession?.id == session.id,
                onSelect: { selectedSession = session },
                onDelete: { onDeleteSession(session) }
            )
        }
    }

    private var newSessionButton: some View {
        Button("+ New Session") {
            onNewSession()
        }
        .padding(Theme.Spacing.medium)
    }
}

// MARK: - Session Row View

/// Individual session row in the sidebar
struct SessionRowView: View {

    // MARK: - Properties

    @ObservedObject var session: Session
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Text(session.statusIcon)

            VStack(alignment: .leading, spacing: Theme.Spacing.tiny) {
                Text(session.displayName)
                    .bold(isSelected)
                Text(session.status.rawValue)
                    .fontSize(Theme.FontSizes.small)
            }
        }
        .padding(Theme.Spacing.medium)
        .background(isSelected ? Theme.Colors.selectedBackground : Color.clear)
        .onClick { onSelect() }
        .contextMenu {
            Button("Delete") { onDelete() }
        }
    }
}

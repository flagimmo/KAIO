import SwiftCrossUI

/// Displays the list of terminal sessions in a sidebar
struct SessionListView: View {

    // MARK: - Properties

    @Binding var sessions: [Session]
    @Binding var selectedSession: Session?
    let onNewSession: () -> Void
    let onDeleteSession: (Session) -> Void
    let width: Double

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            header
            sessionList
            Spacer()
            newSessionButton
        }
        .padding(Theme.Spacing.large)
        .frame(width: width)
    }

    // MARK: - View Components

    private var header: some View {
        HStack {
            Text("Sessions")
                .fontSize(Theme.FontSizes.subheader)
                .bold()

            Spacer()

            // Show current width for debugging (optional)
            Text("\(Int(width))px")
                .fontSize(Theme.FontSizes.tiny)
                .foregroundColor(Theme.Colors.timestamp)
        }
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

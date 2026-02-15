import SwiftCrossUI

/// Displays the list of terminal sessions in a sidebar
struct SessionListView: View {
    @Binding var sessions: [Session]
    @Binding var selectedSession: Session?
    let onNewSession: () -> Void
    let onDeleteSession: (Session) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Sessions")
                    .fontSize(16)
                    .bold()
            }

            // Session list
            ForEach(sessions) { session in
                SessionRowView(
                    session: session,
                    isSelected: selectedSession?.id == session.id,
                    onSelect: { selectedSession = session },
                    onDelete: { onDeleteSession(session) }
                )
            }

            // New session button
            Button("+ New Session") {
                onNewSession()
            }
            .padding(8)
        }
        .padding(12)
        .frame(width: 250)
    }
}

/// Individual session row in the sidebar
struct SessionRowView: View {
    @ObservedObject var session: Session
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(session.statusIcon)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.displayName)
                    .bold(isSelected)
                Text(session.status.rawValue)
                    .fontSize(11)
            }
        }
        .padding(8)
        .background(isSelected ? Color(red: 0.3, green: 0.5, blue: 0.8, opacity: 0.3) : Color.clear)
        .onClick { onSelect() }
        .contextMenu {
            Button("Delete") {
                onDelete()
            }
        }
    }
}

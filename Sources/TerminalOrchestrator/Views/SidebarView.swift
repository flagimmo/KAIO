import SwiftCrossUI

struct SidebarView: View {
    @Environment(SessionManager.self) private var sessionManager

    @State private var newProjectName = ""
    @State private var newSessionName = ""
    @State private var selectedProjectId: UUID?
    @State private var showingNewProjectDialog = false
    @State private var showingNewSessionDialog = false

    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Projects & Sessions")
                    .bold()
                Spacer()
                Button("+") {
                    showingNewProjectDialog = true
                }
            }
            .padding(8)

            // Projects List
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(sessionManager.projects) { project in
                        ProjectRow(
                            project: project,
                            isSelected: selectedProjectId == project.id,
                            onSelect: {
                                selectedProjectId = project.id
                            },
                            onToggle: {
                                var updatedProject = project
                                updatedProject.toggleExpanded()
                                sessionManager.updateProject(updatedProject)
                            },
                            onDelete: {
                                sessionManager.deleteProject(project.id)
                            },
                            onNewSession: {
                                selectedProjectId = project.id
                                showingNewSessionDialog = true
                            }
                        )

                        if project.isExpanded {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(sessionManager.getSessions(for: project.id)) { session in
                                    SessionRow(
                                        session: session,
                                        isActive: sessionManager.activeSessionId == session.id,
                                        onSelect: {
                                            sessionManager.setActiveSession(session.id)
                                        },
                                        onDelete: {
                                            sessionManager.deleteSession(session.id)
                                        }
                                    )
                                    .padding(.leading, 20)
                                }
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .frame(minWidth: 250, maxWidth: 300)
    }
}

struct ProjectRow: View {
    let project: Project
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onNewSession: () -> Void

    var body: some View {
        HStack {
            Button(project.isExpanded ? "▼" : "▶") {
                onToggle()
            }
            .frame(width: 20)

            Text("📁 \(project.name)")
                .onTapGesture {
                    onSelect()
                }

            Spacer()

            Text("\(project.sessionCount)")
                .foregroundColor(.secondary)

            Button("+") {
                onNewSession()
            }
            .frame(width: 25)
        }
        .padding(6)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
    }
}

struct SessionRow: View {
    let session: Session
    let isActive: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text("📌 \(session.name)")
                .onTapGesture {
                    onSelect()
                }

            Spacer()

            if let lastCommand = session.lastCommand {
                Text(lastCommand.isSuccess ? "✓" : "✗")
                    .foregroundColor(lastCommand.isSuccess ? .green : .red)
            }
        }
        .padding(6)
        .background(isActive ? Color.green.opacity(0.2) : Color.clear)
    }
}

import SwiftCrossUI

struct SessionDetailView: View {
    @Environment(SessionManager.self) private var sessionManager
    let sessionId: UUID

    @State private var commandInput = ""
    @State private var isExecuting = false

    var session: Session? {
        sessionManager.getSession(sessionId)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if let session = session {
                    Text("📺 \(session.name)")
                        .bold()
                    Spacer()
                    Text("📂 \(session.workingDirectory)")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(session.commandCount) commands")
                        .foregroundColor(.secondary)
                } else {
                    Text("No session selected")
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.1))

            // Output Area
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if let session = session {
                        ForEach(session.history) { command in
                            CommandOutputView(command: command)
                        }
                    }
                }
                .padding(12)
            }
            .frame(minHeight: 300)

            Spacer()

            // Command Input Area
            VStack(spacing: 8) {
                HStack {
                    Text("$")
                        .bold()
                        .foregroundColor(.green)

                    TextField("Enter command...", text: $commandInput)
                        .disabled(isExecuting)
                        .onSubmit {
                            executeCommand()
                        }

                    Button(isExecuting ? "Running..." : "Run") {
                        executeCommand()
                    }
                    .disabled(commandInput.isEmpty || isExecuting)
                }
                .padding(12)
                .background(Color.gray.opacity(0.05))
            }
        }
    }

    private func executeCommand() {
        guard !commandInput.isEmpty, !isExecuting else { return }

        let command = commandInput
        commandInput = ""
        isExecuting = true

        Task {
            do {
                _ = try await sessionManager.executeCommand(command, in: sessionId)
            } catch {
                print("Error executing command: \(error)")
            }
            isExecuting = false
        }
    }
}

struct CommandOutputView: View {
    let command: Command

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Command line
            HStack {
                Text("$ \(command.command)")
                    .bold()
                    .foregroundColor(.blue)
                Spacer()
                Text(command.timestamp.formatted(date: .omitted, time: .shortened))
                    .foregroundColor(.secondary)
                    .font(.caption)
            }

            // Output
            if !command.output.isEmpty {
                Text(command.output)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(command.isSuccess ? .primary : .red)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
            }

            // Exit code indicator
            if !command.isSuccess {
                Text("Exit code: \(command.exitCode)")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

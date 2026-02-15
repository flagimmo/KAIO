import SwiftCrossUI

/// Displays the details and output of a single terminal session
struct SessionDetailView: View {
    @ObservedObject var session: Session
    @ObservedObject var processManager: ProcessManager
    @State var inputText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Toolbar
            HStack(spacing: 12) {
                Text(session.displayName)
                    .fontSize(18)
                    .bold()

                Text("•")

                Text(session.status.rawValue)
                    .foregroundColor(statusColor)

                // Control buttons
                HStack(spacing: 8) {
                    if session.status == .running {
                        Button("Stop") {
                            processManager.stopSession(session)
                        }

                        Button("Restart") {
                            processManager.restartSession(session)
                        }
                    } else {
                        Button("Start") {
                            processManager.startSession(session)
                        }
                    }

                    Button("Clear") {
                        session.output.removeAll()
                    }
                }
            }
            .padding(12)

            // Output area
            VStack(alignment: .leading, spacing: 4) {
                ForEach(session.output) { line in
                    OutputLineView(line: line)
                }
            }
            .padding(12)
            .frame(minHeight: 300)

            // Input area
            if session.status == .running {
                HStack(spacing: 8) {
                    TextField("Enter command...", text: $inputText)
                        .padding(8)

                    Button("Send") {
                        processManager.sendInput(inputText, to: session)
                        inputText = ""
                    }
                    .padding(8)
                }
                .padding(12)
            }
        }
    }

    private var statusColor: Color {
        switch session.status {
        case .running:
            return Color(red: 0, green: 0.8, blue: 0, opacity: 1.0)
        case .error:
            return Color(red: 0.8, green: 0, blue: 0, opacity: 1.0)
        case .stopped:
            return Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 1.0)
        case .idle:
            return Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0)
        }
    }
}

/// Individual output line view
struct OutputLineView: View {
    let line: OutputLine

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(formatTime(line.timestamp))
                .fontSize(10)
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0))

            Text(line.text)
                .fontSize(12)
                .foregroundColor(lineColor)
        }
    }

    private var lineColor: Color {
        switch line.type {
        case .stdout:
            return Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)
        case .stderr:
            return Color(red: 1.0, green: 0.3, blue: 0.3, opacity: 1.0)
        case .system:
            return Color(red: 0.5, green: 0.8, blue: 1.0, opacity: 1.0)
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

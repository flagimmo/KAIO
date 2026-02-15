import SwiftCrossUI

/// Displays the details and output of a single terminal session
struct SessionDetailView: View {

    // MARK: - Properties

    @ObservedObject var session: Session
    @ObservedObject var processManager: ProcessManager
    @State var inputText: String = ""

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            toolbar
            outputArea
            if session.isRunning {
                inputArea
            }
        }
    }

    // MARK: - View Components

    private var toolbar: some View {
        HStack(spacing: Theme.Spacing.large) {
            Text(session.displayName)
                .fontSize(Theme.FontSizes.header)
                .bold()

            Text("•")

            Text(session.status.rawValue)
                .foregroundColor(statusColor)

            controlButtons
        }
        .padding(Theme.Spacing.large)
    }

    private var controlButtons: some View {
        HStack(spacing: Theme.Spacing.medium) {
            if session.isRunning {
                Button("Stop") { processManager.stopSession(session) }
                Button("Restart") { processManager.restartSession(session) }
            } else {
                Button("Start") { processManager.startSession(session) }
            }
            Button("Clear") { session.clearOutput() }
        }
    }

    private var outputArea: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            ForEach(session.output) { line in
                OutputLineView(line: line)
            }
        }
        .padding(Theme.Spacing.large)
        .frame(minHeight: Theme.Sizes.minContentHeight)
    }

    private var inputArea: some View {
        HStack(spacing: Theme.Spacing.medium) {
            TextField("Enter command...", text: $inputText)
                .padding(Theme.Spacing.medium)

            Button("Send") {
                processManager.sendInput(inputText, to: session)
                inputText = ""
            }
            .padding(Theme.Spacing.medium)
        }
        .padding(Theme.Spacing.large)
    }

    // MARK: - Computed Properties

    private var statusColor: Color {
        switch session.status {
        case .running: return Theme.Colors.running
        case .error: return Theme.Colors.error
        case .stopped: return Theme.Colors.stopped
        case .idle: return Theme.Colors.idle
        }
    }
}

// MARK: - Output Line View

/// Individual output line view
struct OutputLineView: View {
    let line: OutputLine

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            Text(line.formattedTime)
                .fontSize(Theme.FontSizes.tiny)
                .foregroundColor(Theme.Colors.timestamp)

            Text(line.text)
                .fontSize(Theme.FontSizes.caption)
                .foregroundColor(lineColor)
        }
    }

    private var lineColor: Color {
        switch line.type {
        case .stdout: return Theme.Colors.stdout
        case .stderr: return Theme.Colors.stderr
        case .system: return Theme.Colors.system
        }
    }
}

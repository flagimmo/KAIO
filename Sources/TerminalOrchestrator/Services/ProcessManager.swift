import Foundation

/// Manages process execution and lifecycle for terminal sessions
public class ProcessManager: ObservableObject {

    // MARK: - Constants

    private enum Constants {
        static let restartDelay: TimeInterval = 0.5
        static let envExecutable = "/usr/bin/env"
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - Public Methods

    /// Start a session's process
    public func startSession(_ session: Session) {
        guard session.status != .running else {
            session.addOutput("Session is already running", type: .system)
            return
        }

        let process = createProcess(for: session)
        let pipes = setupPipes(for: session, process: process)

        configureProcessTermination(process, session: session)
        executeProcess(process, session: session)
    }

    /// Stop a session's process
    public func stopSession(_ session: Session) {
        guard let process = session.process, process.isRunning else {
            session.addOutput("No running process to stop", type: .system)
            return
        }

        process.terminate()
        session.addOutput("Terminating process...", type: .system)
    }

    /// Send input to a session's process
    public func sendInput(_ input: String, to session: Session) {
        guard let process = session.process,
              process.isRunning,
              let stdin = process.standardInput as? Pipe else {
            session.addOutput("Cannot send input: process not running", type: .system)
            return
        }

        guard let data = (input + "\n").data(using: .utf8) else {
            session.addOutput("Failed to encode input", type: .system)
            return
        }

        do {
            try stdin.fileHandleForWriting.write(contentsOf: data)
            session.addOutput("> \(input)", type: .system)
        } catch {
            session.addOutput("Failed to send input: \(error.localizedDescription)", type: .system)
        }
    }

    /// Restart a session
    public func restartSession(_ session: Session) {
        stopSession(session)
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.restartDelay) { [weak self] in
            self?.startSession(session)
        }
    }

    // MARK: - Private Methods

    private func createProcess(for session: Session) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: Constants.envExecutable)
        process.arguments = [session.tool.command] + session.tool.arguments

        if let workingDir = session.tool.workingDirectory {
            process.currentDirectoryURL = URL(fileURLWithPath: workingDir)
        }

        process.environment = buildEnvironment(for: session.tool)
        return process
    }

    private func buildEnvironment(for tool: CLITool) -> [String: String] {
        var environment = ProcessInfo.processInfo.environment
        tool.environmentVariables.forEach { environment[$0.key] = $0.value }
        return environment
    }

    private struct ProcessPipes {
        let input: Pipe
        let output: Pipe
        let error: Pipe
    }

    private func setupPipes(for session: Session, process: Process) -> ProcessPipes {
        let pipes = ProcessPipes(input: Pipe(), output: Pipe(), error: Pipe())

        process.standardInput = pipes.input
        process.standardOutput = pipes.output
        process.standardError = pipes.error

        setupOutputHandler(pipe: pipes.output, session: session, type: .stdout)
        setupOutputHandler(pipe: pipes.error, session: session, type: .stderr)

        return pipes
    }

    private func setupOutputHandler(pipe: Pipe, session: Session, type: OutputType) {
        pipe.fileHandleForReading.readabilityHandler = { [weak session] handle in
            let data = handle.availableData
            guard !data.isEmpty,
                  let output = String(data: data, encoding: .utf8) else { return }

            DispatchQueue.main.async {
                session?.addOutput(output.trimmingCharacters(in: .newlines), type: type)
            }
        }
    }

    private func configureProcessTermination(_ process: Process, session: Session) {
        process.terminationHandler = { [weak session] process in
            DispatchQueue.main.async {
                let exitCode = process.terminationStatus
                session?.status = exitCode == 0 ? .stopped : .error
                session?.addOutput("Process exited with code \(exitCode)", type: .system)
            }
        }
    }

    private func executeProcess(_ process: Process, session: Session) {
        do {
            try process.run()
            session.process = process
            session.status = .running
            session.startTime = Date()

            let command = "\(session.tool.command) \(session.tool.arguments.joined(separator: " "))"
            session.addOutput("Started: \(command)", type: .system)
        } catch {
            session.status = .error
            session.addOutput("Failed to start process: \(error.localizedDescription)", type: .system)
        }
    }
}

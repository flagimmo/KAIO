import Foundation

/// Manages process execution and lifecycle for terminal sessions
class ProcessManager: ObservableObject {

    /// Start a session's process
    func startSession(_ session: Session) {
        guard session.status != .running else {
            session.addOutput("Session is already running", type: .system)
            return
        }

        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        // Configure process
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        var arguments = [session.tool.command] + session.tool.arguments
        process.arguments = arguments

        // Set working directory if specified
        if let workingDir = session.tool.workingDirectory {
            process.currentDirectoryURL = URL(fileURLWithPath: workingDir)
        }

        // Set environment variables
        var environment = ProcessInfo.processInfo.environment
        for (key, value) in session.tool.environmentVariables {
            environment[key] = value
        }
        process.environment = environment

        // Setup output handling
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Capture stdout
        outputPipe.fileHandleForReading.readabilityHandler = { [weak session] handle in
            let data = handle.availableData
            if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    session?.addOutput(output.trimmingCharacters(in: .newlines), type: .stdout)
                }
            }
        }

        // Capture stderr
        errorPipe.fileHandleForReading.readabilityHandler = { [weak session] handle in
            let data = handle.availableData
            if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    session?.addOutput(output.trimmingCharacters(in: .newlines), type: .stderr)
                }
            }
        }

        // Handle process termination
        process.terminationHandler = { [weak session] process in
            DispatchQueue.main.async {
                if process.terminationStatus == 0 {
                    session?.status = .stopped
                    session?.addOutput("Process exited with code 0", type: .system)
                } else {
                    session?.status = .error
                    session?.addOutput("Process exited with code \(process.terminationStatus)", type: .system)
                }
            }
        }

        do {
            try process.run()
            session.process = process
            session.status = .running
            session.startTime = Date()
            session.addOutput("Started: \(session.tool.command) \(session.tool.arguments.joined(separator: " "))", type: .system)
        } catch {
            session.status = .error
            session.addOutput("Failed to start process: \(error.localizedDescription)", type: .system)
        }
    }

    /// Stop a session's process
    func stopSession(_ session: Session) {
        guard let process = session.process, process.isRunning else {
            session.addOutput("No running process to stop", type: .system)
            return
        }

        process.terminate()
        session.addOutput("Terminating process...", type: .system)
    }

    /// Send input to a session's process
    func sendInput(_ input: String, to session: Session) {
        guard let process = session.process,
              process.isRunning,
              let stdin = process.standardInput as? Pipe else {
            session.addOutput("Cannot send input: process not running", type: .system)
            return
        }

        if let data = (input + "\n").data(using: .utf8) {
            do {
                try stdin.fileHandleForWriting.write(contentsOf: data)
                session.addOutput("> \(input)", type: .system)
            } catch {
                session.addOutput("Failed to send input: \(error.localizedDescription)", type: .system)
            }
        }
    }

    /// Restart a session
    func restartSession(_ session: Session) {
        stopSession(session)

        // Wait a bit before restarting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startSession(session)
        }
    }
}

import Foundation

/// Manages all sessions and projects
@Observable
final class SessionManager {
    var sessions: [UUID: Session] = [:]
    var projects: [Project] = []
    var activeSessionId: UUID?

    private let persistence = PersistenceService()

    init() {
        loadFromDisk()

        // Create default project if none exist
        if projects.isEmpty {
            let defaultSession = Session(name: "Default Session")
            let defaultProject = Project(
                name: "Default Project",
                sessionIds: [defaultSession.id]
            )

            sessions[defaultSession.id] = defaultSession
            projects = [defaultProject]
            activeSessionId = defaultSession.id

            saveToDisk()
        }
    }

    // MARK: - Session Management

    func createSession(name: String, in projectId: UUID? = nil) -> Session {
        let session = Session(name: name)
        sessions[session.id] = session

        if let projectId = projectId,
           let projectIndex = projects.firstIndex(where: { $0.id == projectId }) {
            projects[projectIndex].addSession(session.id)
        } else if let firstProject = projects.first {
            var updatedProject = firstProject
            updatedProject.addSession(session.id)
            projects[0] = updatedProject
        }

        saveToDisk()
        return session
    }

    func deleteSession(_ sessionId: UUID) {
        sessions.removeValue(forKey: sessionId)

        for i in 0..<projects.count {
            projects[i].removeSession(sessionId)
        }

        if activeSessionId == sessionId {
            activeSessionId = sessions.keys.first
        }

        saveToDisk()
    }

    func updateSession(_ session: Session) {
        sessions[session.id] = session
    }

    func getSession(_ sessionId: UUID) -> Session? {
        sessions[sessionId]
    }

    var activeSession: Session? {
        guard let activeSessionId = activeSessionId else { return nil }
        return sessions[activeSessionId]
    }

    func setActiveSession(_ sessionId: UUID) {
        guard sessions[sessionId] != nil else { return }
        activeSessionId = sessionId

        if var session = sessions[sessionId] {
            session.lastAccessedAt = Date()
            sessions[sessionId] = session
        }
    }

    // MARK: - Project Management

    func createProject(name: String) -> Project {
        let project = Project(name: name)
        projects.append(project)
        saveToDisk()
        return project
    }

    func deleteProject(_ projectId: UUID) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }) else {
            return
        }

        let project = projects[projectIndex]

        for sessionId in project.sessionIds {
            sessions.removeValue(forKey: sessionId)
        }

        projects.remove(at: projectIndex)

        if let deletedSessionId = project.sessionIds.first,
           activeSessionId == deletedSessionId {
            activeSessionId = sessions.keys.first
        }

        saveToDisk()
    }

    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveToDisk()
        }
    }

    func getSessions(for projectId: UUID) -> [Session] {
        guard let project = projects.first(where: { $0.id == projectId }) else {
            return []
        }

        return project.sessionIds.compactMap { sessions[$0] }
            .sorted { $0.lastAccessedAt > $1.lastAccessedAt }
    }

    func moveSession(_ sessionId: UUID, to projectId: UUID) {
        for i in 0..<projects.count {
            projects[i].removeSession(sessionId)
        }

        if let projectIndex = projects.firstIndex(where: { $0.id == projectId }) {
            projects[projectIndex].addSession(sessionId)
        }
    }

    // MARK: - Command Execution

    func executeCommand(_ commandText: String, in sessionId: UUID) async throws -> Command {
        guard var session = sessions[sessionId] else {
            throw SessionError.sessionNotFound
        }

        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "cd \(session.workingDirectory) && \(commandText)"]

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        let command = Command(
            command: commandText,
            output: output,
            exitCode: Int(process.terminationStatus)
        )

        session.addCommand(command)
        sessions[sessionId] = session

        saveToDisk()

        return command
    }

    // MARK: - Persistence

    func saveToDisk() {
        do {
            try persistence.saveSessions(sessions)
            try persistence.saveProjects(projects)
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    func loadFromDisk() {
        do {
            sessions = try persistence.loadSessions()
            projects = try persistence.loadProjects()

            if let firstProject = projects.first,
               let firstSessionId = firstProject.sessionIds.first {
                activeSessionId = firstSessionId
            }
        } catch {
            print("Failed to load data: \(error)")
        }
    }

    func clearAll() {
        do {
            try persistence.clearAll()
            sessions.removeAll()
            projects.removeAll()
            activeSessionId = nil
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}

enum SessionError: Error {
    case sessionNotFound
    case invalidWorkingDirectory
}

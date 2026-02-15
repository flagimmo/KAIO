import XCTest
@testable import TerminalOrchestratorCore

final class SessionManagerTests: XCTestCase {

    var sessionManager: SessionManager!

    override func setUp() {
        super.setUp()
        sessionManager = SessionManager()
        // Clear persistence to start fresh
        try? sessionManager.clearAll()
    }

    override func tearDown() {
        try? sessionManager.clearAll()
        sessionManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testSessionManagerInitialization() {
        XCTAssertFalse(sessionManager.projects.isEmpty, "Should have default project")
        XCTAssertFalse(sessionManager.sessions.isEmpty, "Should have default session")
        XCTAssertNotNil(sessionManager.activeSessionId, "Should have active session")
    }

    // MARK: - Session Management Tests

    func testCreateSession() {
        let session = sessionManager.createSession(name: "New Session")

        XCTAssertEqual(session.name, "New Session")
        XCTAssertNotNil(sessionManager.getSession(session.id))
    }

    func testCreateSessionInProject() {
        let project = sessionManager.createProject(name: "Test Project")
        let session = sessionManager.createSession(name: "Project Session", in: project.id)

        let updatedProject = sessionManager.projects.first { $0.id == project.id }
        XCTAssertTrue(updatedProject?.sessionIds.contains(session.id) ?? false)
    }

    func testDeleteSession() {
        let session = sessionManager.createSession(name: "To Delete")
        let sessionId = session.id

        sessionManager.deleteSession(sessionId)

        XCTAssertNil(sessionManager.getSession(sessionId))
    }

    func testDeleteActiveSession() {
        guard let activeId = sessionManager.activeSessionId else {
            XCTFail("Should have active session")
            return
        }

        sessionManager.deleteSession(activeId)

        XCTAssertNotEqual(sessionManager.activeSessionId, activeId, "Active session should change")
    }

    func testUpdateSession() {
        let session = sessionManager.createSession(name: "Original")
        var updatedSession = session
        updatedSession.name = "Updated"

        sessionManager.updateSession(updatedSession)

        let retrieved = sessionManager.getSession(session.id)
        XCTAssertEqual(retrieved?.name, "Updated")
    }

    func testSetActiveSession() {
        let session = sessionManager.createSession(name: "To Activate")

        sessionManager.setActiveSession(session.id)

        XCTAssertEqual(sessionManager.activeSessionId, session.id)
        XCTAssertEqual(sessionManager.activeSession?.id, session.id)
    }

    // MARK: - Project Management Tests

    func testCreateProject() {
        let project = sessionManager.createProject(name: "New Project")

        XCTAssertEqual(project.name, "New Project")
        XCTAssertTrue(sessionManager.projects.contains { $0.id == project.id })
    }

    func testDeleteProject() {
        let project = sessionManager.createProject(name: "To Delete")
        let session = sessionManager.createSession(name: "In Project", in: project.id)

        sessionManager.deleteProject(project.id)

        XCTAssertFalse(sessionManager.projects.contains { $0.id == project.id })
        XCTAssertNil(sessionManager.getSession(session.id), "Sessions in project should be deleted")
    }

    func testUpdateProject() {
        let project = sessionManager.createProject(name: "Original Project")
        var updated = project
        updated.name = "Updated Project"

        sessionManager.updateProject(updated)

        let retrieved = sessionManager.projects.first { $0.id == project.id }
        XCTAssertEqual(retrieved?.name, "Updated Project")
    }

    func testGetSessionsForProject() {
        let project = sessionManager.createProject(name: "Test Project")
        let session1 = sessionManager.createSession(name: "Session 1", in: project.id)
        let session2 = sessionManager.createSession(name: "Session 2", in: project.id)

        let sessions = sessionManager.getSessions(for: project.id)

        XCTAssertEqual(sessions.count, 2)
        XCTAssertTrue(sessions.contains { $0.id == session1.id })
        XCTAssertTrue(sessions.contains { $0.id == session2.id })
    }

    func testMoveSession() {
        let project1 = sessionManager.createProject(name: "Project 1")
        let project2 = sessionManager.createProject(name: "Project 2")
        let session = sessionManager.createSession(name: "Movable", in: project1.id)

        sessionManager.moveSession(session.id, to: project2.id)

        let project1Sessions = sessionManager.getSessions(for: project1.id)
        let project2Sessions = sessionManager.getSessions(for: project2.id)

        XCTAssertFalse(project1Sessions.contains { $0.id == session.id })
        XCTAssertTrue(project2Sessions.contains { $0.id == session.id })
    }

    // MARK: - Command Execution Tests

    func testExecuteCommand() async throws {
        let session = sessionManager.createSession(name: "Command Test")

        let command = try await sessionManager.executeCommand("echo 'test'", in: session.id)

        XCTAssertEqual(command.command, "echo 'test'")
        XCTAssertTrue(command.output.contains("test"))
        XCTAssertEqual(command.exitCode, 0)
        XCTAssertTrue(command.isSuccess)
    }

    func testExecuteCommandUpdatesSession() async throws {
        let session = sessionManager.createSession(name: "Test")

        _ = try await sessionManager.executeCommand("pwd", in: session.id)

        let updatedSession = sessionManager.getSession(session.id)
        XCTAssertEqual(updatedSession?.commandCount, 1)
    }

    func testExecuteFailingCommand() async throws {
        let session = sessionManager.createSession(name: "Test")

        let command = try await sessionManager.executeCommand("false", in: session.id)

        XCTAssertFalse(command.isSuccess)
        XCTAssertNotEqual(command.exitCode, 0)
    }

    func testExecuteCommandInNonExistentSession() async {
        let fakeId = UUID()

        do {
            _ = try await sessionManager.executeCommand("echo test", in: fakeId)
            XCTFail("Should throw error for non-existent session")
        } catch {
            XCTAssertTrue(error is SessionError)
        }
    }

    // MARK: - Edge Cases

    func testMultipleSessionsInMultipleProjects() {
        let project1 = sessionManager.createProject(name: "Project 1")
        let project2 = sessionManager.createProject(name: "Project 2")

        for i in 1...3 {
            _ = sessionManager.createSession(name: "P1-S\(i)", in: project1.id)
            _ = sessionManager.createSession(name: "P2-S\(i)", in: project2.id)
        }

        XCTAssertEqual(sessionManager.getSessions(for: project1.id).count, 3)
        XCTAssertEqual(sessionManager.getSessions(for: project2.id).count, 3)
    }

    func testDeleteProjectWithActiveSession() {
        let project = sessionManager.createProject(name: "Active Project")
        let session = sessionManager.createSession(name: "Active", in: project.id)

        sessionManager.setActiveSession(session.id)

        sessionManager.deleteProject(project.id)

        XCTAssertNotEqual(sessionManager.activeSessionId, session.id)
    }
}

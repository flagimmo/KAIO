import XCTest
@testable import TerminalOrchestratorCore

final class PersistenceServiceTests: XCTestCase {

    var persistence: PersistenceService!

    override func setUp() {
        super.setUp()
        persistence = PersistenceService()
        try? persistence.clearAll()
    }

    override func tearDown() {
        try? persistence.clearAll()
        persistence = nil
        super.tearDown()
    }

    // MARK: - Session Persistence Tests

    func testSaveAndLoadSessions() throws {
        let session1 = Session(name: "Session 1", workingDirectory: "/home")
        let session2 = Session(name: "Session 2", workingDirectory: "/tmp")

        let sessions: [UUID: Session] = [
            session1.id: session1,
            session2.id: session2
        ]

        try persistence.saveSessions(sessions)

        let loaded = try persistence.loadSessions()

        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[session1.id]?.name, "Session 1")
        XCTAssertEqual(loaded[session2.id]?.name, "Session 2")
    }

    func testLoadSessionsWhenFileDoesNotExist() throws {
        let loaded = try persistence.loadSessions()
        XCTAssertTrue(loaded.isEmpty, "Should return empty dictionary when no file exists")
    }

    func testSaveSessionsWithCommandHistory() throws {
        var session = Session(name: "Test")
        session.addCommand(Command(command: "ls", output: "files", exitCode: 0))
        session.addCommand(Command(command: "pwd", output: "/home", exitCode: 0))

        let sessions = [session.id: session]

        try persistence.saveSessions(sessions)
        let loaded = try persistence.loadSessions()

        let loadedSession = loaded[session.id]
        XCTAssertEqual(loadedSession?.commandCount, 2)
        XCTAssertEqual(loadedSession?.history.first?.command, "ls")
    }

    // MARK: - Project Persistence Tests

    func testSaveAndLoadProjects() throws {
        let sessionId1 = UUID()
        let sessionId2 = UUID()

        let project1 = Project(name: "Project 1", sessionIds: [sessionId1])
        let project2 = Project(name: "Project 2", sessionIds: [sessionId2])

        let projects = [project1, project2]

        try persistence.saveProjects(projects)

        let loaded = try persistence.loadProjects()

        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].name, "Project 1")
        XCTAssertEqual(loaded[1].name, "Project 2")
    }

    func testLoadProjectsWhenFileDoesNotExist() throws {
        let loaded = try persistence.loadProjects()
        XCTAssertTrue(loaded.isEmpty, "Should return empty array when no file exists")
    }

    func testSaveProjectsWithMetadata() throws {
        let project = Project(
            name: "Colored Project",
            sessionIds: [UUID(), UUID()],
            colorHex: "#FF5733",
            isExpanded: false
        )

        try persistence.saveProjects([project])
        let loaded = try persistence.loadProjects()

        XCTAssertEqual(loaded.first?.colorHex, "#FF5733")
        XCTAssertEqual(loaded.first?.isExpanded, false)
        XCTAssertEqual(loaded.first?.sessionCount, 2)
    }

    // MARK: - Clear Tests

    func testClearAll() throws {
        let session = Session(name: "Test")
        let project = Project(name: "Test")

        try persistence.saveSessions([session.id: session])
        try persistence.saveProjects([project])

        try persistence.clearAll()

        let loadedSessions = try persistence.loadSessions()
        let loadedProjects = try persistence.loadProjects()

        XCTAssertTrue(loadedSessions.isEmpty)
        XCTAssertTrue(loadedProjects.isEmpty)
    }

    func testClearAllWhenFilesDoNotExist() throws {
        try persistence.clearAll()  // Should not throw
    }

    // MARK: - Data Integrity Tests

    func testSaveAndLoadPreservesAllFields() throws {
        let command = Command(
            command: "test command",
            output: "test output",
            timestamp: Date(),
            exitCode: 0
        )

        var session = Session(
            name: "Detailed Session",
            workingDirectory: "/test/dir",
            history: [command],
            createdAt: Date(),
            lastAccessedAt: Date()
        )

        let sessions = [session.id: session]

        try persistence.saveSessions(sessions)
        let loaded = try persistence.loadSessions()

        let loadedSession = loaded[session.id]
        XCTAssertEqual(loadedSession?.name, session.name)
        XCTAssertEqual(loadedSession?.workingDirectory, session.workingDirectory)
        XCTAssertEqual(loadedSession?.commandCount, 1)
    }

    // MARK: - Edge Cases

    func testSaveEmptySessions() throws {
        try persistence.saveSessions([:])

        let loaded = try persistence.loadSessions()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testSaveEmptyProjects() throws {
        try persistence.saveProjects([])

        let loaded = try persistence.loadProjects()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testSaveLargeSessionHistory() throws {
        var session = Session(name: "Large History")

        for i in 1...100 {
            session.addCommand(Command(command: "cmd\(i)", exitCode: 0))
        }

        try persistence.saveSessions([session.id: session])
        let loaded = try persistence.loadSessions()

        XCTAssertEqual(loaded[session.id]?.commandCount, 100)
    }

    func testOverwriteExistingData() throws {
        let session1 = Session(name: "First")
        try persistence.saveSessions([session1.id: session1])

        let session2 = Session(name: "Second")
        try persistence.saveSessions([session2.id: session2])

        let loaded = try persistence.loadSessions()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[session2.id]?.name, "Second")
    }
}

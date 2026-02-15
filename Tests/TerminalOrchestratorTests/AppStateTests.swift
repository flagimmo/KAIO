import XCTest
@testable import TerminalOrchestratorCore

/// Tests for AppState - Application state management
@MainActor
final class AppStateTests: XCTestCase {

    // MARK: - Properties

    private var sut: AppState!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Create without demo session for clean testing
        sut = AppState(createDemoSession: false)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_withoutDemoSession_startsEmpty() {
        // Assert
        XCTAssertTrue(sut.sessions.isEmpty)
        XCTAssertNil(sut.selectedSession)
    }

    func test_init_withDemoSession_createsDemoSession() {
        // Arrange & Act
        let appState = AppState(createDemoSession: true)

        // Assert
        XCTAssertEqual(appState.sessions.count, 1)
        XCTAssertNotNil(appState.selectedSession)
        XCTAssertEqual(appState.sessions.first?.tool.name, "Demo: Echo Server")
    }

    // MARK: - Create Session Tests

    func test_createNewSession_withDefaultTool_addsSession() {
        // Act
        sut.createNewSession()

        // Assert
        XCTAssertEqual(sut.sessions.count, 1)
        XCTAssertNotNil(sut.selectedSession)
    }

    func test_createNewSession_selectsNewSession() {
        // Act
        sut.createNewSession()

        // Assert
        XCTAssertEqual(sut.selectedSession?.id, sut.sessions.first?.id)
    }

    func test_createNewSession_withCustomTool_usesProvidedTool() {
        // Arrange
        let customTool = CLITool(
            name: "Custom Tool",
            command: "test",
            arguments: ["arg1"]
        )

        // Act
        sut.createNewSession(tool: customTool)

        // Assert
        XCTAssertEqual(sut.sessions.count, 1)
        XCTAssertEqual(sut.sessions.first?.tool.name, "Custom Tool")
        XCTAssertEqual(sut.sessions.first?.tool.command, "test")
    }

    func test_createNewSession_multiple_addsAllSessions() {
        // Act
        sut.createNewSession()
        sut.createNewSession()
        sut.createNewSession()

        // Assert
        XCTAssertEqual(sut.sessions.count, 3)
    }

    func test_createNewSession_updatesSelection() {
        // Arrange
        sut.createNewSession() // First session
        let firstSession = sut.selectedSession

        // Act
        sut.createNewSession() // Second session

        // Assert
        XCTAssertNotEqual(sut.selectedSession?.id, firstSession?.id)
        XCTAssertEqual(sut.selectedSession?.id, sut.sessions.last?.id)
    }

    // MARK: - Delete Session Tests

    func test_deleteSession_removesSession() {
        // Arrange
        sut.createNewSession()
        let session = sut.sessions.first!

        // Act
        sut.deleteSession(session)

        // Assert
        XCTAssertTrue(sut.sessions.isEmpty)
    }

    func test_deleteSession_whenSelected_updatesSelection() {
        // Arrange
        sut.createNewSession() // First session
        sut.createNewSession() // Second session
        let firstSession = sut.sessions.first!
        sut.selectedSession = firstSession

        // Act
        sut.deleteSession(firstSession)

        // Assert
        XCTAssertNotEqual(sut.selectedSession?.id, firstSession.id)
        XCTAssertEqual(sut.selectedSession?.id, sut.sessions.first?.id)
    }

    func test_deleteSession_whenNotSelected_keepsSelection() {
        // Arrange
        sut.createNewSession() // First session
        sut.createNewSession() // Second session
        let firstSession = sut.sessions.first!
        let secondSession = sut.sessions.last!
        sut.selectedSession = secondSession

        // Act
        sut.deleteSession(firstSession)

        // Assert
        XCTAssertEqual(sut.selectedSession?.id, secondSession.id)
    }

    func test_deleteSession_lastSession_clearsSelection() {
        // Arrange
        sut.createNewSession()
        let session = sut.sessions.first!

        // Act
        sut.deleteSession(session)

        // Assert
        XCTAssertNil(sut.selectedSession)
        XCTAssertTrue(sut.sessions.isEmpty)
    }

    func test_deleteSession_multipleSessionsRemaining_selectsFirst() {
        // Arrange
        sut.createNewSession() // Session 1
        sut.createNewSession() // Session 2
        sut.createNewSession() // Session 3
        let sessionToDelete = sut.sessions[1]
        sut.selectedSession = sessionToDelete

        // Act
        sut.deleteSession(sessionToDelete)

        // Assert
        XCTAssertEqual(sut.sessions.count, 2)
        XCTAssertEqual(sut.selectedSession?.id, sut.sessions.first?.id)
    }

    // MARK: - Integration Tests

    func test_createAndDeleteMultipleSessions_maintainsCorrectState() {
        // Arrange & Act
        sut.createNewSession() // Session 1
        sut.createNewSession() // Session 2
        sut.createNewSession() // Session 3

        let session1 = sut.sessions[0]
        let session2 = sut.sessions[1]

        sut.deleteSession(session1)
        XCTAssertEqual(sut.sessions.count, 2)

        sut.createNewSession() // Session 4
        XCTAssertEqual(sut.sessions.count, 3)

        sut.deleteSession(session2)
        XCTAssertEqual(sut.sessions.count, 2)

        // Assert - Final state
        XCTAssertEqual(sut.sessions.count, 2)
        XCTAssertNotNil(sut.selectedSession)
    }

    func test_sessionSelection_canBeChangedManually() {
        // Arrange
        sut.createNewSession() // Session 1
        sut.createNewSession() // Session 2
        let session1 = sut.sessions[0]
        let session2 = sut.sessions[1]

        // Act
        sut.selectedSession = session1
        XCTAssertEqual(sut.selectedSession?.id, session1.id)

        sut.selectedSession = session2
        XCTAssertEqual(sut.selectedSession?.id, session2.id)

        sut.selectedSession = nil
        XCTAssertNil(sut.selectedSession)
    }
}

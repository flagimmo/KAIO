import XCTest
@testable import TerminalOrchestratorCore

final class ProjectTests: XCTestCase {

    // MARK: - Initialization Tests

    func testProjectInitialization() {
        let project = Project(name: "Test Project")

        XCTAssertEqual(project.name, "Test Project")
        XCTAssertTrue(project.sessionIds.isEmpty)
        XCTAssertEqual(project.sessionCount, 0)
        XCTAssertTrue(project.isExpanded)
        XCTAssertNil(project.colorHex)
    }

    func testProjectWithSessions() {
        let sessionId1 = UUID()
        let sessionId2 = UUID()

        let project = Project(
            name: "Multi-Session",
            sessionIds: [sessionId1, sessionId2]
        )

        XCTAssertEqual(project.sessionCount, 2)
        XCTAssertTrue(project.sessionIds.contains(sessionId1))
        XCTAssertTrue(project.sessionIds.contains(sessionId2))
    }

    // MARK: - Session Management Tests

    func testAddSession() {
        var project = Project(name: "Test")
        let sessionId = UUID()

        project.addSession(sessionId)

        XCTAssertEqual(project.sessionCount, 1)
        XCTAssertTrue(project.sessionIds.contains(sessionId))
    }

    func testAddDuplicateSession() {
        var project = Project(name: "Test")
        let sessionId = UUID()

        project.addSession(sessionId)
        project.addSession(sessionId)  // Add again

        XCTAssertEqual(project.sessionCount, 1, "Should not add duplicate session")
    }

    func testRemoveSession() {
        let sessionId1 = UUID()
        let sessionId2 = UUID()

        var project = Project(
            name: "Test",
            sessionIds: [sessionId1, sessionId2]
        )

        project.removeSession(sessionId1)

        XCTAssertEqual(project.sessionCount, 1)
        XCTAssertFalse(project.sessionIds.contains(sessionId1))
        XCTAssertTrue(project.sessionIds.contains(sessionId2))
    }

    func testRemoveNonExistentSession() {
        var project = Project(name: "Test", sessionIds: [UUID()])
        let initialCount = project.sessionCount

        project.removeSession(UUID())  // Random UUID

        XCTAssertEqual(project.sessionCount, initialCount)
    }

    // MARK: - Expansion Tests

    func testToggleExpanded() {
        var project = Project(name: "Test", isExpanded: true)

        XCTAssertTrue(project.isExpanded)

        project.toggleExpanded()
        XCTAssertFalse(project.isExpanded)

        project.toggleExpanded()
        XCTAssertTrue(project.isExpanded)
    }

    // MARK: - Color Tests

    func testProjectWithColor() {
        let project = Project(
            name: "Colored",
            colorHex: "#FF5733"
        )

        XCTAssertEqual(project.colorHex, "#FF5733")
    }

    // MARK: - Codable Tests

    func testProjectEncodable() throws {
        let project = Project(
            name: "Encodable",
            sessionIds: [UUID(), UUID()],
            colorHex: "#00FF00"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(project)

        XCTAssertFalse(data.isEmpty)
    }

    func testProjectDecodable() throws {
        let sessionId = UUID()
        let project = Project(
            name: "Decodable",
            sessionIds: [sessionId],
            colorHex: "#0000FF"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(project)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Project.self, from: data)

        XCTAssertEqual(decoded.name, project.name)
        XCTAssertEqual(decoded.sessionIds, project.sessionIds)
        XCTAssertEqual(decoded.colorHex, project.colorHex)
        XCTAssertEqual(decoded.isExpanded, project.isExpanded)
    }

    // MARK: - Equatable Tests

    func testProjectEquality() {
        let id = UUID()
        let project1 = Project(id: id, name: "Test")
        let project2 = Project(id: id, name: "Test")

        XCTAssertEqual(project1, project2)
    }

    func testProjectInequality() {
        let project1 = Project(name: "Project 1")
        let project2 = Project(name: "Project 2")

        XCTAssertNotEqual(project1, project2)
    }

    // MARK: - Edge Cases

    func testProjectWithEmptyName() {
        let project = Project(name: "")
        XCTAssertTrue(project.name.isEmpty)
    }

    func testProjectWithManySessions() {
        var sessionIds: [UUID] = []
        for _ in 1...50 {
            sessionIds.append(UUID())
        }

        let project = Project(name: "Many Sessions", sessionIds: sessionIds)

        XCTAssertEqual(project.sessionCount, 50)
    }

    func testProjectCollapsed() {
        let project = Project(name: "Collapsed", isExpanded: false)
        XCTAssertFalse(project.isExpanded)
    }
}

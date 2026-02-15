import XCTest
@testable import TerminalOrchestratorCore

final class NewSessionTests: XCTestCase {

    // MARK: - Initialization Tests

    func testSessionInitialization() {
        let session = Session(
            name: "Test Session",
            workingDirectory: "/tmp"
        )

        XCTAssertEqual(session.name, "Test Session")
        XCTAssertEqual(session.workingDirectory, "/tmp")
        XCTAssertTrue(session.history.isEmpty)
        XCTAssertEqual(session.commandCount, 0)
        XCTAssertNil(session.lastCommand)
    }

    func testSessionWithDefaultWorkingDirectory() {
        let session = Session(name: "Default Session")

        XCTAssertEqual(session.workingDirectory, FileManager.default.currentDirectoryPath)
    }

    // MARK: - Command Management Tests

    func testAddCommand() {
        var session = Session(name: "Test")
        let command = Command(command: "ls", output: "files", exitCode: 0)

        session.addCommand(command)

        XCTAssertEqual(session.commandCount, 1)
        XCTAssertEqual(session.lastCommand?.command, "ls")
    }

    func testAddMultipleCommands() {
        var session = Session(name: "Test")

        for i in 1...5 {
            let command = Command(command: "command\(i)", exitCode: 0)
            session.addCommand(command)
        }

        XCTAssertEqual(session.commandCount, 5)
        XCTAssertEqual(session.lastCommand?.command, "command5")
    }

    func testClearHistory() {
        var session = Session(name: "Test")

        for i in 1...3 {
            session.addCommand(Command(command: "cmd\(i)", exitCode: 0))
        }

        XCTAssertEqual(session.commandCount, 3)

        session.clearHistory()

        XCTAssertEqual(session.commandCount, 0)
        XCTAssertNil(session.lastCommand)
    }

    // MARK: - Timestamp Tests

    func testLastAccessedAtUpdatesOnAddCommand() throws {
        var session = Session(name: "Test")
        let initialTime = session.lastAccessedAt

        Thread.sleep(forTimeInterval: 0.1)

        session.addCommand(Command(command: "test", exitCode: 0))

        XCTAssertGreaterThan(session.lastAccessedAt, initialTime)
    }

    // MARK: - Codable Tests

    func testSessionEncodable() throws {
        let session = Session(
            name: "Encodable Test",
            workingDirectory: "/test",
            history: [
                Command(command: "ls", output: "files", exitCode: 0)
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(session)

        XCTAssertFalse(data.isEmpty)
    }

    func testSessionDecodable() throws {
        let command = Command(command: "pwd", output: "/home", exitCode: 0)
        let session = Session(
            name: "Decodable Test",
            workingDirectory: "/home",
            history: [command]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(session)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Session.self, from: data)

        XCTAssertEqual(decoded.name, session.name)
        XCTAssertEqual(decoded.workingDirectory, session.workingDirectory)
        XCTAssertEqual(decoded.commandCount, session.commandCount)
    }

    // MARK: - Equatable Tests

    func testSessionEquality() {
        let id = UUID()
        let session1 = Session(id: id, name: "Test")
        let session2 = Session(id: id, name: "Test")

        XCTAssertEqual(session1, session2)
    }

    func testSessionInequality() {
        let session1 = Session(name: "Session 1")
        let session2 = Session(name: "Session 2")

        XCTAssertNotEqual(session1, session2)
    }

    // MARK: - Edge Cases

    func testSessionWithEmptyName() {
        let session = Session(name: "")
        XCTAssertTrue(session.name.isEmpty)
    }

    func testSessionWithLongHistory() {
        var session = Session(name: "Long History")

        for i in 1...100 {
            session.addCommand(Command(command: "cmd\(i)", exitCode: 0))
        }

        XCTAssertEqual(session.commandCount, 100)
        XCTAssertEqual(session.lastCommand?.command, "cmd100")
    }

    func testSessionWithMixedSuccessFailureCommands() {
        var session = Session(name: "Mixed")

        session.addCommand(Command(command: "success", exitCode: 0))
        session.addCommand(Command(command: "fail", exitCode: 1))
        session.addCommand(Command(command: "success2", exitCode: 0))

        XCTAssertEqual(session.commandCount, 3)
        XCTAssertTrue(session.history[0].isSuccess)
        XCTAssertFalse(session.history[1].isSuccess)
        XCTAssertTrue(session.history[2].isSuccess)
    }
}

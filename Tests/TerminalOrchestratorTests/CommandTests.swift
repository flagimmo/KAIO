import XCTest
@testable import TerminalOrchestratorCore

final class CommandTests: XCTestCase {

    // MARK: - Initialization Tests

    func testCommandInitialization() {
        let command = Command(
            command: "ls -la",
            output: "file1.txt\nfile2.txt",
            exitCode: 0
        )

        XCTAssertFalse(command.command.isEmpty)
        XCTAssertEqual(command.command, "ls -la")
        XCTAssertEqual(command.output, "file1.txt\nfile2.txt")
        XCTAssertEqual(command.exitCode, 0)
        XCTAssertTrue(command.isSuccess)
    }

    func testCommandWithDefaultValues() {
        let command = Command(command: "pwd")

        XCTAssertEqual(command.command, "pwd")
        XCTAssertEqual(command.output, "")
        XCTAssertEqual(command.exitCode, 0)
        XCTAssertTrue(command.isSuccess)
    }

    // MARK: - Success/Failure Tests

    func testCommandSuccess() {
        let command = Command(command: "echo 'hello'", exitCode: 0)
        XCTAssertTrue(command.isSuccess)
    }

    func testCommandFailure() {
        let command = Command(command: "invalid-command", exitCode: 127)
        XCTAssertFalse(command.isSuccess)
    }

    func testCommandNonZeroExitCode() {
        let command = Command(command: "grep pattern file.txt", exitCode: 1)
        XCTAssertFalse(command.isSuccess)
    }

    // MARK: - Codable Tests

    func testCommandEncodable() throws {
        let command = Command(
            command: "git status",
            output: "On branch main",
            exitCode: 0
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(command)

        XCTAssertFalse(data.isEmpty)
    }

    func testCommandDecodable() throws {
        let command = Command(
            command: "git status",
            output: "On branch main",
            exitCode: 0
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(command)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Command.self, from: data)

        XCTAssertEqual(decoded.command, command.command)
        XCTAssertEqual(decoded.output, command.output)
        XCTAssertEqual(decoded.exitCode, command.exitCode)
    }

    // MARK: - Equatable Tests

    func testCommandEquality() {
        let command1 = Command(id: UUID(), command: "ls", output: "files", exitCode: 0)
        let command2 = command1

        XCTAssertEqual(command1, command2)
    }

    func testCommandInequality() {
        let command1 = Command(command: "ls")
        let command2 = Command(command: "pwd")

        XCTAssertNotEqual(command1, command2)
    }

    // MARK: - Edge Cases

    func testCommandWithEmptyOutput() {
        let command = Command(command: "true", output: "", exitCode: 0)

        XCTAssertTrue(command.output.isEmpty)
        XCTAssertTrue(command.isSuccess)
    }

    func testCommandWithMultilineOutput() {
        let output = """
        line1
        line2
        line3
        """
        let command = Command(command: "cat file.txt", output: output, exitCode: 0)

        XCTAssertEqual(command.output, output)
        XCTAssertTrue(command.output.contains("\n"))
    }

    func testCommandWithSpecialCharacters() {
        let command = Command(
            command: "echo 'hello & world | grep > test'",
            output: "hello & world | grep > test",
            exitCode: 0
        )

        XCTAssertTrue(command.command.contains("&"))
        XCTAssertTrue(command.command.contains("|"))
        XCTAssertTrue(command.command.contains(">"))
    }
}

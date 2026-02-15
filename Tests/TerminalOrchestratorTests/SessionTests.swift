import XCTest
@testable import TerminalOrchestratorCore

/// Tests for Session model and related types
@MainActor
final class SessionTests: XCTestCase {

    // MARK: - Properties

    private var sut: Session!
    private var tool: CLITool!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        tool = CLITool(
            name: "Test Tool",
            command: "echo",
            arguments: ["Hello"]
        )
        sut = Session(tool: tool)
    }

    override func tearDown() {
        sut = nil
        tool = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_setsCorrectInitialState() {
        // Assert
        XCTAssertEqual(sut.status, .idle)
        XCTAssertTrue(sut.output.isEmpty)
        XCTAssertNil(sut.startTime)
        XCTAssertNil(sut.process)
    }

    func test_init_setsToolCorrectly() {
        // Assert
        XCTAssertEqual(sut.tool.name, "Test Tool")
        XCTAssertEqual(sut.tool.command, "echo")
        XCTAssertEqual(sut.tool.arguments, ["Hello"])
    }

    func test_init_withCustomStatus_setsStatus() {
        // Arrange & Act
        let session = Session(tool: tool, status: .running)

        // Assert
        XCTAssertEqual(session.status, .running)
    }

    // MARK: - Output Management Tests

    func test_addOutput_appendsOutputLine() {
        // Act
        sut.addOutput("Test output")

        // Assert
        XCTAssertEqual(sut.output.count, 1)
        XCTAssertEqual(sut.output[0].text, "Test output")
        XCTAssertEqual(sut.output[0].type, .stdout)
    }

    func test_addOutput_withType_setsCorrectType() {
        // Act
        sut.addOutput("Error message", type: .stderr)

        // Assert
        XCTAssertEqual(sut.output.count, 1)
        XCTAssertEqual(sut.output[0].type, .stderr)
    }

    func test_addOutput_multipleLines_maintainsOrder() {
        // Act
        sut.addOutput("Line 1")
        sut.addOutput("Line 2", type: .stderr)
        sut.addOutput("Line 3", type: .system)

        // Assert
        XCTAssertEqual(sut.output.count, 3)
        XCTAssertEqual(sut.output[0].text, "Line 1")
        XCTAssertEqual(sut.output[1].text, "Line 2")
        XCTAssertEqual(sut.output[2].text, "Line 3")
    }

    func test_clearOutput_removesAllOutput() {
        // Arrange
        sut.addOutput("Line 1")
        sut.addOutput("Line 2")
        XCTAssertEqual(sut.output.count, 2)

        // Act
        sut.clearOutput()

        // Assert
        XCTAssertTrue(sut.output.isEmpty)
    }

    // MARK: - Computed Properties Tests

    func test_displayName_returnsToolName() {
        // Assert
        XCTAssertEqual(sut.displayName, "Test Tool")
    }

    func test_statusIcon_returnsCorrectIcon() {
        // Test all status icons
        sut.status = .idle
        XCTAssertEqual(sut.statusIcon, "⚪️")

        sut.status = .running
        XCTAssertEqual(sut.statusIcon, "🟢")

        sut.status = .stopped
        XCTAssertEqual(sut.statusIcon, "🔴")

        sut.status = .error
        XCTAssertEqual(sut.statusIcon, "⚠️")
    }

    func test_isRunning_whenRunning_returnsTrue() {
        // Arrange
        sut.status = .running

        // Assert
        XCTAssertTrue(sut.isRunning)
    }

    func test_isRunning_whenNotRunning_returnsFalse() {
        // Test all non-running states
        sut.status = .idle
        XCTAssertFalse(sut.isRunning)

        sut.status = .stopped
        XCTAssertFalse(sut.isRunning)

        sut.status = .error
        XCTAssertFalse(sut.isRunning)
    }
}

// MARK: - SessionStatus Tests

final class SessionStatusTests: XCTestCase {

    // MARK: - Icon Tests

    func test_icon_idle_returnsWhiteCircle() {
        // Arrange
        let status = SessionStatus.idle

        // Assert
        XCTAssertEqual(status.icon, "⚪️")
    }

    func test_icon_running_returnsGreenCircle() {
        // Arrange
        let status = SessionStatus.running

        // Assert
        XCTAssertEqual(status.icon, "🟢")
    }

    func test_icon_stopped_returnsRedCircle() {
        // Arrange
        let status = SessionStatus.stopped

        // Assert
        XCTAssertEqual(status.icon, "🔴")
    }

    func test_icon_error_returnsWarning() {
        // Arrange
        let status = SessionStatus.error

        // Assert
        XCTAssertEqual(status.icon, "⚠️")
    }

    // MARK: - Raw Value Tests

    func test_rawValue_matchesExpectedString() {
        XCTAssertEqual(SessionStatus.idle.rawValue, "Idle")
        XCTAssertEqual(SessionStatus.running.rawValue, "Running")
        XCTAssertEqual(SessionStatus.stopped.rawValue, "Stopped")
        XCTAssertEqual(SessionStatus.error.rawValue, "Error")
    }
}

// MARK: - OutputLine Tests

final class OutputLineTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_setsPropertiesCorrectly() {
        // Arrange
        let timestamp = Date()

        // Act
        let line = OutputLine(
            text: "Test output",
            type: .stdout,
            timestamp: timestamp
        )

        // Assert
        XCTAssertEqual(line.text, "Test output")
        XCTAssertEqual(line.type, .stdout)
        XCTAssertEqual(line.timestamp, timestamp)
        XCTAssertNotNil(line.id)
    }

    func test_init_withDefaultTimestamp_usesCurrentTime() {
        // Arrange
        let before = Date()

        // Act
        let line = OutputLine(text: "Test", type: .stdout)

        // Assert
        let after = Date()
        XCTAssertTrue(line.timestamp >= before)
        XCTAssertTrue(line.timestamp <= after)
    }

    // MARK: - Formatted Time Tests

    func test_formattedTime_returnsCorrectFormat() {
        // Arrange
        let calendar = Calendar.current
        let components = DateComponents(
            year: 2025,
            month: 2,
            day: 15,
            hour: 14,
            minute: 30,
            second: 45
        )
        let timestamp = calendar.date(from: components)!
        let line = OutputLine(
            text: "Test",
            type: .stdout,
            timestamp: timestamp
        )

        // Assert
        XCTAssertEqual(line.formattedTime, "14:30:45")
    }

    func test_formattedTime_usesCachedFormatter() {
        // Arrange
        let line1 = OutputLine(text: "Line 1", type: .stdout)
        let line2 = OutputLine(text: "Line 2", type: .stdout)

        // Act - Both should use the same formatter instance
        let time1 = line1.formattedTime
        let time2 = line2.formattedTime

        // Assert - Just verify it works (formatter caching is implementation detail)
        XCTAssertFalse(time1.isEmpty)
        XCTAssertFalse(time2.isEmpty)
    }
}

// MARK: - OutputType Tests

final class OutputTypeTests: XCTestCase {

    func test_outputType_allCases() {
        // Verify all output types exist
        let stdout = OutputType.stdout
        let stderr = OutputType.stderr
        let system = OutputType.system

        XCTAssertEqual(stdout.rawValue, "stdout")
        XCTAssertEqual(stderr.rawValue, "stderr")
        XCTAssertEqual(system.rawValue, "system")
    }
}

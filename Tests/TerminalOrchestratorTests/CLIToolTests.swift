import XCTest
@testable import TerminalOrchestratorCore

/// Tests for CLITool model
final class CLIToolTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withMinimalParameters_createsToolCorrectly() {
        // Arrange & Act
        let tool = CLITool(
            name: "Test Tool",
            command: "echo"
        )

        // Assert
        XCTAssertEqual(tool.name, "Test Tool")
        XCTAssertEqual(tool.command, "echo")
        XCTAssertTrue(tool.arguments.isEmpty)
        XCTAssertNil(tool.workingDirectory)
        XCTAssertTrue(tool.environmentVariables.isEmpty)
        XCTAssertNotNil(tool.id)
    }

    func test_init_withAllParameters_setsAllProperties() {
        // Arrange
        let customID = UUID()
        let env = ["KEY": "VALUE"]

        // Act
        let tool = CLITool(
            id: customID,
            name: "Full Tool",
            command: "bash",
            arguments: ["-c", "echo test"],
            workingDirectory: "/tmp",
            environmentVariables: env
        )

        // Assert
        XCTAssertEqual(tool.id, customID)
        XCTAssertEqual(tool.name, "Full Tool")
        XCTAssertEqual(tool.command, "bash")
        XCTAssertEqual(tool.arguments, ["-c", "echo test"])
        XCTAssertEqual(tool.workingDirectory, "/tmp")
        XCTAssertEqual(tool.environmentVariables, env)
    }

    func test_init_generatesUniqueIDs() {
        // Arrange & Act
        let tool1 = CLITool(name: "Tool 1", command: "cmd1")
        let tool2 = CLITool(name: "Tool 2", command: "cmd2")

        // Assert
        XCTAssertNotEqual(tool1.id, tool2.id)
    }

    // MARK: - Presets Tests

    func test_presets_containsExpectedTools() {
        // Assert
        XCTAssertFalse(CLITool.presets.isEmpty)
        XCTAssertTrue(CLITool.presets.count >= 5)
    }

    func test_presets_claudeCode_exists() {
        // Arrange
        let claudeCode = CLITool.presets.first { $0.name == "Claude Code" }

        // Assert
        XCTAssertNotNil(claudeCode)
        XCTAssertEqual(claudeCode?.command, "claude")
        XCTAssertEqual(claudeCode?.arguments, ["code"])
    }

    func test_presets_geminiCLI_exists() {
        // Arrange
        let gemini = CLITool.presets.first { $0.name == "Gemini CLI" }

        // Assert
        XCTAssertNotNil(gemini)
        XCTAssertEqual(gemini?.command, "gemini")
    }

    func test_presets_githubCopilot_exists() {
        // Arrange
        let copilot = CLITool.presets.first { $0.name == "GitHub Copilot CLI" }

        // Assert
        XCTAssertNotNil(copilot)
        XCTAssertEqual(copilot?.command, "gh")
        XCTAssertEqual(copilot?.arguments, ["copilot"])
    }

    func test_presets_customShell_exists() {
        // Arrange
        let shell = CLITool.presets.first { $0.name == "Custom Shell" }

        // Assert
        XCTAssertNotNil(shell)
        XCTAssertEqual(shell?.command, "/bin/bash")
        XCTAssertEqual(shell?.arguments, ["-l"])
    }

    func test_presets_allHaveUniqueIDs() {
        // Arrange
        let ids = CLITool.presets.map { $0.id }
        let uniqueIDs = Set(ids)

        // Assert
        XCTAssertEqual(ids.count, uniqueIDs.count)
    }

    func test_presets_allHaveNonEmptyNames() {
        // Assert
        for preset in CLITool.presets {
            XCTAssertFalse(preset.name.isEmpty, "Preset has empty name")
            XCTAssertFalse(preset.command.isEmpty, "Preset has empty command")
        }
    }

    // MARK: - Codable Tests

    func test_codable_encodesAndDecodes() throws {
        // Arrange
        let original = CLITool(
            name: "Test Tool",
            command: "test",
            arguments: ["arg1", "arg2"],
            workingDirectory: "/home/user",
            environmentVariables: ["KEY1": "VALUE1", "KEY2": "VALUE2"]
        )

        // Act - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        // Act - Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CLITool.self, from: data)

        // Assert
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.command, original.command)
        XCTAssertEqual(decoded.arguments, original.arguments)
        XCTAssertEqual(decoded.workingDirectory, original.workingDirectory)
        XCTAssertEqual(decoded.environmentVariables, original.environmentVariables)
    }

    func test_codable_withNilValues_encodesAndDecodes() throws {
        // Arrange
        let original = CLITool(
            name: "Minimal Tool",
            command: "cmd"
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CLITool.self, from: data)

        // Assert
        XCTAssertNil(decoded.workingDirectory)
        XCTAssertTrue(decoded.arguments.isEmpty)
        XCTAssertTrue(decoded.environmentVariables.isEmpty)
    }

    // MARK: - Identifiable Tests

    func test_identifiable_conformance() {
        // Arrange
        let tool = CLITool(name: "Test", command: "test")

        // Assert - Compiler will enforce Identifiable conformance
        let _: UUID = tool.id
    }
}

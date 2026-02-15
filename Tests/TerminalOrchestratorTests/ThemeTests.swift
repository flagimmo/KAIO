import XCTest
@testable import TerminalOrchestratorCore

/// Tests for Theme constants
final class ThemeTests: XCTestCase {

    // MARK: - Colors Tests

    func test_colors_statusColors_areDefined() {
        // Assert - Just verify they exist and don't crash
        let _ = Theme.Colors.running
        let _ = Theme.Colors.error
        let _ = Theme.Colors.stopped
        let _ = Theme.Colors.idle
    }

    func test_colors_outputColors_areDefined() {
        // Assert
        let _ = Theme.Colors.stdout
        let _ = Theme.Colors.stderr
        let _ = Theme.Colors.system
    }

    func test_colors_uiColors_areDefined() {
        // Assert
        let _ = Theme.Colors.selectedBackground
        let _ = Theme.Colors.timestamp
        let _ = Theme.Colors.emptyStateText
        let _ = Theme.Colors.emptyStateSubtext
    }

    // MARK: - Sizes Tests

    func test_sizes_areDefined() {
        // Assert
        XCTAssertEqual(Theme.Sizes.sidebarWidth, 250)
        XCTAssertEqual(Theme.Sizes.minContentWidth, 400)
        XCTAssertEqual(Theme.Sizes.minContentHeight, 300)
        XCTAssertEqual(Theme.Sizes.minWindowWidth, 800)
        XCTAssertEqual(Theme.Sizes.minWindowHeight, 600)
    }

    func test_sizes_haveReasonableValues() {
        // Assert - Sizes should be positive and reasonable
        XCTAssertGreaterThan(Theme.Sizes.sidebarWidth, 0)
        XCTAssertGreaterThan(Theme.Sizes.minContentWidth, 0)
        XCTAssertGreaterThan(Theme.Sizes.minContentHeight, 0)
        XCTAssertGreaterThan(Theme.Sizes.minWindowWidth, Theme.Sizes.sidebarWidth)
        XCTAssertGreaterThan(Theme.Sizes.minWindowHeight, Theme.Sizes.minContentHeight)
    }

    // MARK: - Font Sizes Tests

    func test_fontSizes_areDefined() {
        // Assert
        XCTAssertEqual(Theme.FontSizes.header, 18)
        XCTAssertEqual(Theme.FontSizes.subheader, 16)
        XCTAssertEqual(Theme.FontSizes.body, 14)
        XCTAssertEqual(Theme.FontSizes.caption, 12)
        XCTAssertEqual(Theme.FontSizes.small, 11)
        XCTAssertEqual(Theme.FontSizes.tiny, 10)
    }

    func test_fontSizes_areInCorrectOrder() {
        // Assert - Font sizes should be ordered from largest to smallest
        XCTAssertGreaterThan(Theme.FontSizes.header, Theme.FontSizes.subheader)
        XCTAssertGreaterThan(Theme.FontSizes.subheader, Theme.FontSizes.body)
        XCTAssertGreaterThan(Theme.FontSizes.body, Theme.FontSizes.caption)
        XCTAssertGreaterThan(Theme.FontSizes.caption, Theme.FontSizes.small)
        XCTAssertGreaterThan(Theme.FontSizes.small, Theme.FontSizes.tiny)
    }

    func test_fontSizes_haveReasonableValues() {
        // Assert - Font sizes should be readable (> 8, < 30)
        XCTAssertGreaterThan(Theme.FontSizes.tiny, 8)
        XCTAssertLessThan(Theme.FontSizes.header, 30)
    }

    // MARK: - Spacing Tests

    func test_spacing_areDefined() {
        // Assert
        XCTAssertEqual(Theme.Spacing.tiny, 2)
        XCTAssertEqual(Theme.Spacing.small, 4)
        XCTAssertEqual(Theme.Spacing.medium, 8)
        XCTAssertEqual(Theme.Spacing.large, 12)
        XCTAssertEqual(Theme.Spacing.extraLarge, 16)
    }

    func test_spacing_areInCorrectOrder() {
        // Assert - Spacing should be ordered from smallest to largest
        XCTAssertLessThan(Theme.Spacing.tiny, Theme.Spacing.small)
        XCTAssertLessThan(Theme.Spacing.small, Theme.Spacing.medium)
        XCTAssertLessThan(Theme.Spacing.medium, Theme.Spacing.large)
        XCTAssertLessThan(Theme.Spacing.large, Theme.Spacing.extraLarge)
    }

    func test_spacing_haveReasonableValues() {
        // Assert - Spacing should be positive and reasonable
        XCTAssertGreaterThan(Theme.Spacing.tiny, 0)
        XCTAssertLessThan(Theme.Spacing.extraLarge, 50)
    }

    // MARK: - Consistency Tests

    func test_theme_allConstantsAreAccessible() {
        // This test verifies that all Theme enums are properly structured
        // and don't throw any runtime errors when accessed

        // Colors
        let _ = Theme.Colors.running
        let _ = Theme.Colors.error
        let _ = Theme.Colors.stopped
        let _ = Theme.Colors.idle
        let _ = Theme.Colors.stdout
        let _ = Theme.Colors.stderr
        let _ = Theme.Colors.system
        let _ = Theme.Colors.selectedBackground
        let _ = Theme.Colors.timestamp
        let _ = Theme.Colors.emptyStateText
        let _ = Theme.Colors.emptyStateSubtext

        // Sizes
        let _ = Theme.Sizes.sidebarWidth
        let _ = Theme.Sizes.minContentWidth
        let _ = Theme.Sizes.minContentHeight
        let _ = Theme.Sizes.minWindowWidth
        let _ = Theme.Sizes.minWindowHeight

        // Font Sizes
        let _ = Theme.FontSizes.header
        let _ = Theme.FontSizes.subheader
        let _ = Theme.FontSizes.body
        let _ = Theme.FontSizes.caption
        let _ = Theme.FontSizes.small
        let _ = Theme.FontSizes.tiny

        // Spacing
        let _ = Theme.Spacing.tiny
        let _ = Theme.Spacing.small
        let _ = Theme.Spacing.medium
        let _ = Theme.Spacing.large
        let _ = Theme.Spacing.extraLarge

        // If we get here without crashing, all constants are accessible
        XCTAssertTrue(true)
    }
}

import XCTest
@testable import TerminalOrchestratorCore

/// Tests for edge cases in sidebar resizing and persistence
final class EdgeCaseTests: XCTestCase {

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        UserDefaultsKeys.resetAll()
    }

    override func tearDown() {
        UserDefaultsKeys.resetAll()
        super.tearDown()
    }

    // MARK: - Invalid Value Edge Cases

    func test_sidebarWidth_withNegativeValue_returnsDefault() {
        // Arrange - Manually set invalid value
        UserDefaults.standard.set(-100.0, forKey: UserDefaultsKeys.sidebarWidth)

        // Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert - Should return default instead of negative
        XCTAssertEqual(width, Theme.Sizes.sidebarWidth)
    }

    func test_sidebarWidth_withZero_returnsDefault() {
        // Arrange
        UserDefaults.standard.set(0.0, forKey: UserDefaultsKeys.sidebarWidth)

        // Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert
        XCTAssertEqual(width, Theme.Sizes.sidebarWidth)
    }

    func test_sidebarWidth_withInfinity_returnsDefault() {
        // Arrange
        UserDefaults.standard.set(Double.infinity, forKey: UserDefaultsKeys.sidebarWidth)

        // Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert
        XCTAssertEqual(width, Theme.Sizes.sidebarWidth)
        XCTAssertTrue(width.isFinite)
    }

    func test_sidebarWidth_withNaN_returnsDefault() {
        // Arrange
        UserDefaults.standard.set(Double.nan, forKey: UserDefaultsKeys.sidebarWidth)

        // Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert
        XCTAssertEqual(width, Theme.Sizes.sidebarWidth)
        XCTAssertFalse(width.isNaN)
    }

    // MARK: - Out of Range Edge Cases

    func test_sidebarWidth_withValueBelowMin_clampsToMin() {
        // Arrange - Value below minimum
        UserDefaults.standard.set(50.0, forKey: UserDefaultsKeys.sidebarWidth)

        // Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert - Should clamp to minimum
        XCTAssertEqual(width, Theme.Sizes.sidebarMinWidth)
        XCTAssertEqual(width, 150.0)
    }

    func test_sidebarWidth_withValueAboveMax_clampsToMax() {
        // Arrange - Value above maximum
        UserDefaults.standard.set(1000.0, forKey: UserDefaultsKeys.sidebarWidth)

        // Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert - Should clamp to maximum
        XCTAssertEqual(width, Theme.Sizes.sidebarMaxWidth)
        XCTAssertEqual(width, 500.0)
    }

    // MARK: - Setter Edge Cases

    func test_sidebarWidth_settingNegative_doesNotStore() {
        // Act
        UserDefaults.standard.sidebarWidth = -200.0

        // Assert - Should not store invalid value
        XCTAssertFalse(UserDefaults.standard.hasSidebarWidthStored)
    }

    func test_sidebarWidth_settingInfinity_doesNotStore() {
        // Act
        UserDefaults.standard.sidebarWidth = Double.infinity

        // Assert
        XCTAssertFalse(UserDefaults.standard.hasSidebarWidthStored)
    }

    func test_sidebarWidth_settingNaN_doesNotStore() {
        // Act
        UserDefaults.standard.sidebarWidth = Double.nan

        // Assert
        XCTAssertFalse(UserDefaults.standard.hasSidebarWidthStored)
    }

    func test_sidebarWidth_settingBelowMin_clampsAndStores() {
        // Act
        UserDefaults.standard.sidebarWidth = 100.0

        // Assert - Should clamp to min before storing
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, Theme.Sizes.sidebarMinWidth)
    }

    func test_sidebarWidth_settingAboveMax_clampsAndStores() {
        // Act
        UserDefaults.standard.sidebarWidth = 800.0

        // Assert - Should clamp to max before storing
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, Theme.Sizes.sidebarMaxWidth)
    }

    // MARK: - Boundary Value Tests

    func test_sidebarWidth_atMinimum_storesCorrectly() {
        // Act
        UserDefaults.standard.sidebarWidth = Theme.Sizes.sidebarMinWidth

        // Assert
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, 150.0)
        XCTAssertTrue(UserDefaults.standard.hasSidebarWidthStored)
    }

    func test_sidebarWidth_atMaximum_storesCorrectly() {
        // Act
        UserDefaults.standard.sidebarWidth = Theme.Sizes.sidebarMaxWidth

        // Assert
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, 500.0)
        XCTAssertTrue(UserDefaults.standard.hasSidebarWidthStored)
    }

    func test_sidebarWidth_withVerySmallPositive_clampsToMin() {
        // Arrange
        UserDefaults.standard.set(0.001, forKey: UserDefaultsKeys.sidebarWidth)

        // Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert
        XCTAssertEqual(width, Theme.Sizes.sidebarMinWidth)
    }

    func test_sidebarWidth_withVeryLargeNumber_clampsToMax() {
        // Arrange
        UserDefaults.standard.set(Double.greatestFiniteMagnitude, forKey: UserDefaultsKeys.sidebarWidth)

        // Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert
        XCTAssertEqual(width, Theme.Sizes.sidebarMaxWidth)
        XCTAssertTrue(width.isFinite)
    }

    // MARK: - Data Corruption Tests

    func test_sidebarWidth_afterManualCorruption_recoversGracefully() {
        // Arrange - Corrupt data with wrong type
        UserDefaults.standard.set("invalid", forKey: UserDefaultsKeys.sidebarWidth)

        // Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert - Should return default
        XCTAssertEqual(width, Theme.Sizes.sidebarWidth)
    }
}

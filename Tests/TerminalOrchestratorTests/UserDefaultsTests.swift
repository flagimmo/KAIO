import XCTest
@testable import TerminalOrchestratorCore

/// Tests for UserDefaults persistence
final class UserDefaultsTests: XCTestCase {

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Clear any existing values
        UserDefaultsKeys.resetAll()
    }

    override func tearDown() {
        // Clean up after tests
        UserDefaultsKeys.resetAll()
        super.tearDown()
    }

    // MARK: - Sidebar Width Tests

    func test_sidebarWidth_withNoStoredValue_returnsDefault() {
        // Arrange & Act
        let width = UserDefaults.standard.sidebarWidth

        // Assert
        XCTAssertEqual(width, Theme.Sizes.sidebarWidth)
        XCTAssertEqual(width, 250.0)
    }

    func test_sidebarWidth_afterSetting_returnsStoredValue() {
        // Arrange
        let customWidth = 350.0

        // Act
        UserDefaults.standard.sidebarWidth = customWidth

        // Assert
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, customWidth)
    }

    func test_sidebarWidth_persistsAcrossSessions() {
        // Arrange
        let customWidth = 420.0
        UserDefaults.standard.sidebarWidth = customWidth

        // Act - Simulate new instance reading the value
        let retrievedWidth = UserDefaults.standard.sidebarWidth

        // Assert
        XCTAssertEqual(retrievedWidth, customWidth)
    }

    func test_hasSidebarWidthStored_withNoValue_returnsFalse() {
        // Assert
        XCTAssertFalse(UserDefaults.standard.hasSidebarWidthStored)
    }

    func test_hasSidebarWidthStored_afterSetting_returnsTrue() {
        // Arrange
        UserDefaults.standard.sidebarWidth = 300.0

        // Assert
        XCTAssertTrue(UserDefaults.standard.hasSidebarWidthStored)
    }

    func test_resetAll_clearsStoredWidth() {
        // Arrange
        UserDefaults.standard.sidebarWidth = 400.0
        XCTAssertTrue(UserDefaults.standard.hasSidebarWidthStored)

        // Act
        UserDefaultsKeys.resetAll()

        // Assert
        XCTAssertFalse(UserDefaults.standard.hasSidebarWidthStored)
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, Theme.Sizes.sidebarWidth)
    }

    func test_sidebarWidth_withMultipleUpdates_storesLatest() {
        // Arrange & Act
        UserDefaults.standard.sidebarWidth = 200.0
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, 200.0)

        UserDefaults.standard.sidebarWidth = 300.0
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, 300.0)

        UserDefaults.standard.sidebarWidth = 450.0
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, 450.0)

        // Assert - Latest value is stored
        let finalWidth = UserDefaults.standard.sidebarWidth
        XCTAssertEqual(finalWidth, 450.0)
    }

    func test_sidebarWidth_withEdgeValues_handlesCorrectly() {
        // Test minimum
        UserDefaults.standard.sidebarWidth = Theme.Sizes.sidebarMinWidth
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, 150.0)

        // Test maximum
        UserDefaults.standard.sidebarWidth = Theme.Sizes.sidebarMaxWidth
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, 500.0)

        // Test default
        UserDefaultsKeys.resetAll()
        XCTAssertEqual(UserDefaults.standard.sidebarWidth, Theme.Sizes.sidebarWidth)
    }

    // MARK: - Integration Tests

    func test_userDefaultsKeys_sidebarWidthKey_isCorrect() {
        // Assert
        XCTAssertEqual(UserDefaultsKeys.sidebarWidth, "app.sidebar.width")
    }
}

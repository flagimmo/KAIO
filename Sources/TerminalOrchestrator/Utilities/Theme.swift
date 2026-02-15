import SwiftCrossUI

/// Centralized theme constants for consistent UI
public enum Theme {

    // MARK: - Colors

    public enum Colors {
        // Status colors
        static let running = Color(red: 0, green: 0.8, blue: 0, opacity: 1.0)
        static let error = Color(red: 0.8, green: 0, blue: 0, opacity: 1.0)
        static let stopped = Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 1.0)
        static let idle = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0)

        // Output colors
        static let stdout = Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)
        static let stderr = Color(red: 1.0, green: 0.3, blue: 0.3, opacity: 1.0)
        static let system = Color(red: 0.5, green: 0.8, blue: 1.0, opacity: 1.0)

        // UI colors
        static let selectedBackground = Color(red: 0.3, green: 0.5, blue: 0.8, opacity: 0.3)
        static let timestamp = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0)
        static let emptyStateText = Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 1.0)
        static let emptyStateSubtext = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0)
    }

    // MARK: - Sizes

    public enum Sizes {
        static let sidebarWidth: Double = 250
        static let minContentWidth: Double = 400
        static let minContentHeight: Double = 300
        static let minWindowWidth: Double = 800
        static let minWindowHeight: Double = 600
    }

    // MARK: - Font Sizes

    public enum FontSizes {
        static let header: Int = 18
        static let subheader: Int = 16
        static let body: Int = 14
        static let caption: Int = 12
        static let small: Int = 11
        static let tiny: Int = 10
    }

    // MARK: - Spacing

    public enum Spacing {
        static let tiny: Double = 2
        static let small: Double = 4
        static let medium: Double = 8
        static let large: Double = 12
        static let extraLarge: Double = 16
    }
}

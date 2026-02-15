import Foundation

/// UserDefaults keys for persistent app settings
public enum UserDefaultsKeys {
    /// Key for storing sidebar width
    public static let sidebarWidth = "app.sidebar.width"

    /// Reset all settings to defaults
    public static func resetAll() {
        UserDefaults.standard.removeObject(forKey: sidebarWidth)
    }
}

/// Extension for easy UserDefaults access
public extension UserDefaults {

    /// Get/Set sidebar width from UserDefaults
    var sidebarWidth: Double {
        get {
            let width = double(forKey: UserDefaultsKeys.sidebarWidth)

            // Edge case: No value stored or invalid value (0.0, negative, NaN, infinity)
            guard width > 0, width.isFinite else {
                return Theme.Sizes.sidebarWidth
            }

            // Edge case: Value outside valid range - clamp to constraints
            let clampedWidth = min(
                max(width, Theme.Sizes.sidebarMinWidth),
                Theme.Sizes.sidebarMaxWidth
            )

            return clampedWidth
        }
        set {
            // Edge case: Prevent storing invalid values
            guard newValue > 0, newValue.isFinite else {
                // Don't store invalid values - remove key instead
                removeObject(forKey: UserDefaultsKeys.sidebarWidth)
                return
            }

            // Edge case: Clamp to valid range before storing
            let clampedValue = min(
                max(newValue, Theme.Sizes.sidebarMinWidth),
                Theme.Sizes.sidebarMaxWidth
            )

            set(clampedValue, forKey: UserDefaultsKeys.sidebarWidth)
        }
    }

    /// Check if sidebar width has been customized
    var hasSidebarWidthStored: Bool {
        object(forKey: UserDefaultsKeys.sidebarWidth) != nil
    }
}

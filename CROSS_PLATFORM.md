# 🌍 Cross-Platform Architecture

## SwiftCrossUI - Write Once, Run Anywhere

Terminal Orchestrator uses **SwiftCrossUI** for true cross-platform UI.

---

## 📱 Platform Matrix

| Platform | Status | Backend | Support Level |
|----------|--------|---------|---------------|
| **macOS** | ✅ Production | AppKit | ⭐⭐⭐⭐⭐ Full |
| **Linux** | 🚧 Experimental | GTK | ⭐⭐⭐ Partial |
| **Windows** | 🚧 Planned | Win32 | ⭐⭐ Limited |
| **iOS** | 🔜 Future | SwiftUI | ⭐⭐⭐⭐ Possible |

---

## 🏗️ How SwiftCrossUI Works

```
Your Code (SwiftUI-like API)
         ↓
   SwiftCrossUI
         ↓
    ┌────┴────┬────────┬─────────┐
    ↓         ↓        ↓         ↓
  AppKit    GTK+    Win32    SwiftUI
  (macOS) (Linux) (Windows)  (iOS)
```

### Example
```swift
// Same code works on all platforms!
struct MyView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            Button("Click me") { }
        }
    }
}

// SwiftCrossUI translates to:
// - macOS: NSStackView + NSTextField + NSButton
// - Linux: GtkBox + GtkLabel + GtkButton  
// - Windows: WinForms StackPanel + Label + Button
```

---

## 🎯 Platform-Specific Features

### Universal (All Platforms)
- ✅ VStack, HStack, ZStack layouts
- ✅ Text, Button, TextField
- ✅ Colors, Fonts, Spacing
- ✅ @State, @Binding, @ObservedObject
- ✅ onClick, onHover gestures

### macOS Specific
- ✅ Context menus (.contextMenu)
- ✅ Window chrome
- ✅ Native AppKit controls
- ✅ Menu bar integration

### Linux (GTK)
- 🚧 Basic widgets supported
- 🚧 Limited gesture support
- ⚠️ No context menus yet

### Windows
- 🔜 Planned support
- 🔜 Win32 backend in development

---

## 🛠️ Building for Different Platforms

### macOS (Primary)
```bash
swift build
swift run TerminalOrchestrator
```

### Linux (Experimental)
```bash
# Install GTK development headers
sudo apt-get install libgtk-3-dev

# Build
swift build
./build/debug/TerminalOrchestrator
```

### Windows (Future)
```powershell
# Install Swift for Windows
# Build with WinSDK
swift build -Xcc -I/path/to/winsdk
```

---

## 📊 Feature Compatibility

| Feature | macOS | Linux | Windows | iOS |
|---------|-------|-------|---------|-----|
| Multi-window | ✅ | 🚧 | 🔜 | N/A |
| Resizable panels | ✅ | ✅ | 🔜 | ✅ |
| Context menus | ✅ | ❌ | 🔜 | ✅ |
| Drag gestures | ✅ | 🚧 | 🔜 | ✅ |
| Process spawning | ✅ | ✅ | ⚠️ | ❌ |
| File I/O | ✅ | ✅ | ✅ | ✅ |
| UserDefaults | ✅ | ✅ | ✅ | ✅ |

---

## 🎨 Platform UI Differences

### macOS (Native Look)
```
┌─────────────────────────────────┐
│ ⚫⚫⚫  Terminal Orchestrator     │ ← Native window chrome
├─────────────────────────────────┤
│ Sidebar │ Content Area          │ ← AppKit NSStackView
│ ⚪️ Idle  │ Output...             │
│ 🟢 Run  │                       │
└─────────────────────────────────┘
```

### Linux GTK
```
┌─────────────────────────────────┐
│ Terminal Orchestrator      [X]  │ ← GTK window decoration
├─────────────────────────────────┤
│ Sidebar │ Content Area          │ ← GtkBox layout
│ ⚪️ Idle  │ Output...             │
│ 🟢 Run  │                       │
└─────────────────────────────────┘
```

### Windows (Planned)
```
┌─────────────────────────────────┐
│ Terminal Orchestrator    ─ □ ✕ │ ← Win32 chrome
├─────────────────────────────────┤
│ Sidebar │ Content Area          │ ← WinForms layout
│ ⚪️ Idle  │ Output...             │
│ 🟢 Run  │                       │
└─────────────────────────────────┘
```

---

## 🔧 Platform Abstraction

### Process Management
```swift
// Cross-platform process spawning
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
process.arguments = ["bash", "-c", "echo hello"]
try process.run()

// Works on:
// - macOS: Foundation.Process
// - Linux: Foundation.Process
// - Windows: Different backend needed
```

### UserDefaults
```swift
// Cross-platform persistence
UserDefaults.standard.set(250.0, forKey: "width")
let width = UserDefaults.standard.double(forKey: "width")

// Storage location:
// - macOS: ~/Library/Preferences/com.yourapp.plist
// - Linux: ~/.config/yourapp/settings.json
// - Windows: Registry or AppData
```

---

## 🚀 Deployment

### macOS App Bundle
```bash
# Create .app bundle
# (Future enhancement)
productbuild --component TerminalOrchestrator.app \
  /Applications TerminalOrchestrator.pkg
```

### Linux Package
```bash
# Create .deb package
dpkg-deb --build terminal-orchestrator
```

### Windows Installer
```powershell
# Create .msi installer
# (Future)
```

---

## 📝 Code Portability Tips

### ✅ DO: Use SwiftCrossUI abstractions
```swift
VStack { }  // ✅ Cross-platform
HStack { }  // ✅ Works everywhere
Button { }  // ✅ Native on all platforms
```

### ❌ DON'T: Use platform-specific APIs
```swift
#if os(macOS)
import AppKit  // ❌ macOS only
NSWindow()     // ❌ Won't compile on Linux
#endif
```

### ✅ DO: Use conditional compilation sparingly
```swift
#if os(macOS)
  // macOS-specific feature
  .contextMenu { }
#else
  // Fallback for other platforms
  .onClick { showMenu() }
#endif
```

---

## 🎯 Current Focus

**Terminal Orchestrator** is currently optimized for:
- ✅ **macOS** (primary platform)
- 🧪 **Linux** (experimental support)

Future releases may expand to other platforms as SwiftCrossUI matures.

---

## 📚 Resources

- [SwiftCrossUI GitHub](https://github.com/moreSwift/swift-cross-ui)
- [Swift.org - Cross-Platform](https://swift.org)
- [SwiftUI API Compatibility](https://developer.apple.com/documentation/swiftui)


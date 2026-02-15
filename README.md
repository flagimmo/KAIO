# Terminal Orchestrator

A cross-platform desktop app for managing multiple AI coding CLI sessions (Claude Code, Gemini CLI, Codex CLI, etc.) without Xcode.

## Features

- **Multi-Session Management**: Run multiple AI CLI tools simultaneously
- **Process Orchestration**: Start, stop, and restart CLI processes
- **Real-time Output**: View stdout/stderr from all sessions
- **Interactive Input**: Send commands to running sessions
- **Cross-Platform**: Runs on macOS and Linux (via SwiftCrossUI)
- **No Xcode Required**: Built entirely with Swift Package Manager and swift-bundler

## Architecture

```
Sources/TerminalOrchestrator/
├── Models/
│   ├── CLITool.swift          # CLI tool configurations
│   └── Session.swift          # Session state and output
├── Services/
│   └── ProcessManager.swift   # Process execution and lifecycle
├── Views/
│   ├── MainView.swift         # Main container
│   ├── SessionListView.swift  # Session sidebar
│   └── SessionDetailView.swift # Session output and controls
├── OrchestratorApp.swift      # App state and definition
└── main.swift                 # Entry point
```

## Prerequisites

### On macOS (Local Development)

1. **Swift 5.9+** (comes with Xcode Command Line Tools)
   ```bash
   xcode-select --install
   ```

2. **swift-bundler** (for creating .app bundles)
   ```bash
   # Install via Homebrew
   brew install swift-bundler

   # Or build from source
   git clone https://github.com/stackotter/swift-bundler
   cd swift-bundler
   swift build -c release
   cp .build/release/swift-bundler /usr/local/bin/
   ```

### In the Cloud (Linux Development)

1. **Swift 5.9+**
   ```bash
   # Ubuntu/Debian
   wget https://swift.org/builds/swift-5.9-release/ubuntu2204/swift-5.9-RELEASE/swift-5.9-RELEASE-ubuntu22.04.tar.gz
   tar xzf swift-5.9-RELEASE-ubuntu22.04.tar.gz
   sudo mv swift-5.9-RELEASE-ubuntu22.04 /usr/share/swift
   echo 'export PATH=/usr/share/swift/usr/bin:$PATH' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **swift-bundler**
   ```bash
   git clone https://github.com/stackotter/swift-bundler
   cd swift-bundler
   swift build -c release
   sudo cp .build/release/swift-bundler /usr/local/bin/
   ```

## Development Workflow

### Cloud → Local Development

#### 1. Cloud Development (Linux)

```bash
# Clone the repository
git clone <your-repo-url>
cd TerminalOrchestrator

# Fetch dependencies
swift package resolve

# Build the project
swift build

# Run in development mode (Linux - no .app bundle)
swift run TerminalOrchestrator
```

#### 2. Local Development (macOS)

```bash
# Clone the repository
git clone <your-repo-url>
cd TerminalOrchestrator

# Fetch dependencies
swift package resolve

# Build and run with swift-bundler
swift bundler run

# Or build a distributable .app bundle
swift bundler bundle

# The .app will be in: .build/bundler/outputs/TerminalOrchestrator.app
# You can then run it with:
open .build/bundler/outputs/TerminalOrchestrator.app
```

## Common Commands

### Swift Package Manager

```bash
# Resolve dependencies
swift package resolve

# Build in debug mode
swift build

# Build in release mode
swift build -c release

# Run the executable directly (no GUI on Linux)
swift run

# Clean build artifacts
swift package clean

# Update dependencies
swift package update

# Generate Xcode project (optional, for editing only)
swift package generate-xcodeproj
```

### swift-bundler

```bash
# Run the app in development mode (macOS only)
swift bundler run

# Build a .app bundle (macOS)
swift bundler bundle

# Build for release (optimized)
swift bundler bundle --release

# Clean bundler build cache
swift bundler clean

# Show bundler version
swift bundler --version
```

## Configuration

### Adding New CLI Tools

Edit `Sources/TerminalOrchestrator/Models/CLITool.swift` to add preset tools:

```swift
static let presets: [CLITool] = [
    CLITool(
        name: "Your CLI Tool",
        command: "your-command",
        arguments: ["--flag", "value"],
        environmentVariables: ["API_KEY": "your-key"]
    ),
    // ... more presets
]
```

### Customizing the App Bundle

Edit `Bundler.toml` to customize:

- App name and version
- Bundle identifier
- Minimum macOS version
- App icon
- Info.plist entries

## Project Structure

```
.
├── Package.swift              # SPM package definition
├── Bundler.toml              # swift-bundler configuration
├── README.md                 # This file
└── Sources/
    └── TerminalOrchestrator/ # Main app source
```

## Troubleshooting

### "Command not found: swift"

Make sure Swift is installed and in your PATH:
```bash
swift --version
```

### "Command not found: swift-bundler"

Install swift-bundler (see Prerequisites section).

### App crashes on launch

Check the console output for error messages:
```bash
swift bundler run
```

### Process doesn't start

Verify the CLI tool command is correct and the executable is in your PATH:
```bash
which claude    # or your CLI tool
echo $PATH
```

## Platform-Specific Notes

### macOS
- Requires macOS 11.0 (Big Sur) or later
- Uses AppKit backend via SwiftCrossUI
- Full .app bundle support with swift-bundler

### Linux
- Uses GTK backend via SwiftCrossUI
- No .app bundle (run with `swift run`)
- Requires GTK development libraries:
  ```bash
  sudo apt-get install libgtk-3-dev
  ```

## Technology Stack

- **Swift 5.9+**: Programming language
- **SwiftCrossUI**: Cross-platform UI framework
- **Swift Package Manager**: Dependency management
- **swift-bundler**: macOS .app bundle creation

## Resources

- [SwiftCrossUI Documentation](https://swiftcrossui.dev/)
- [swift-bundler Documentation](https://swiftbundler.dev/)
- [Swift Package Manager Guide](https://swift.org/package-manager/)

## License

Copyright © 2026 KAIO. All rights reserved.

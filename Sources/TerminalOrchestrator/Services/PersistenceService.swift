import Foundation

/// Service responsible for persisting and loading session data
/// Follows SoC: Only handles data persistence, no business logic
final class PersistenceService {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Storage Paths

    private var documentsDirectory: URL {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access documents directory")
        }
        return url
    }

    private var storageDirectory: URL {
        documentsDirectory.appendingPathComponent("TerminalOrchestrator", isDirectory: true)
    }

    private var sessionsFileURL: URL {
        storageDirectory.appendingPathComponent("sessions.json")
    }

    private var projectsFileURL: URL {
        storageDirectory.appendingPathComponent("projects.json")
    }

    // MARK: - Initialization

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601

        createStorageDirectoryIfNeeded()
    }

    // MARK: - Public Methods

    /// Save sessions to disk
    func saveSessions(_ sessions: [UUID: Session]) throws {
        let sessionsArray = Array(sessions.values)
        let data = try encoder.encode(sessionsArray)
        try data.write(to: sessionsFileURL, options: .atomic)
    }

    /// Load sessions from disk
    func loadSessions() throws -> [UUID: Session] {
        guard fileManager.fileExists(atPath: sessionsFileURL.path) else {
            return [:]
        }

        let data = try Data(contentsOf: sessionsFileURL)
        let sessionsArray = try decoder.decode([Session].self, from: data)

        // Convert array to dictionary using reduce (DRY)
        return sessionsArray.reduce(into: [:]) { $0[$1.id] = $1 }
    }

    /// Save projects to disk
    func saveProjects(_ projects: [Project]) throws {
        let data = try encoder.encode(projects)
        try data.write(to: projectsFileURL, options: .atomic)
    }

    /// Load projects from disk
    func loadProjects() throws -> [Project] {
        guard fileManager.fileExists(atPath: projectsFileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: projectsFileURL)
        return try decoder.decode([Project].self, from: data)
    }

    /// Clear all persisted data
    func clearAll() throws {
        if fileManager.fileExists(atPath: sessionsFileURL.path) {
            try fileManager.removeItem(at: sessionsFileURL)
        }
        if fileManager.fileExists(atPath: projectsFileURL.path) {
            try fileManager.removeItem(at: projectsFileURL)
        }
    }

    // MARK: - Private Methods

    private func createStorageDirectoryIfNeeded() {
        guard !fileManager.fileExists(atPath: storageDirectory.path) else {
            return
        }

        do {
            try fileManager.createDirectory(
                at: storageDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("Failed to create storage directory: \(error)")
        }
    }
}

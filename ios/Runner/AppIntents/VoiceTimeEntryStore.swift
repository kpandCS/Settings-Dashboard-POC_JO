import Foundation

/// Shared storage bridging Siri (running the App Intent, possibly while
/// Runner isn't in the foreground) and the Flutter side of the app. Entries
/// are appended here by `LogTimeIntent` and drained by `AppDelegate`'s
/// `consumePendingEntries` method channel handler the next time the app
/// launches or resumes.
///
/// Requires the "App Groups" capability with `appGroupId` added in both the
/// Apple Developer portal and the Runner target's entitlements.
@available(iOS 16.0, *)
enum VoiceTimeEntryStore {
    static let appGroupId = "group.com.eg.settingsScreenPoc.voicetime"
    private static let pendingEntriesKey = "pending_voice_time_entries"

    struct PendingVoiceTimeEntry: Codable {
        let id: String
        let projectName: String
        let activityName: String
        let hours: Double
        let loggedAt: Date

        var asDictionary: [String: Any] {
            [
                "id": id,
                "projectName": projectName,
                "activityName": activityName,
                "hours": hours,
                "loggedAt": ISO8601DateFormatter().string(from: loggedAt),
            ]
        }
    }

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    static func appendEntry(_ entry: PendingVoiceTimeEntry) {
        guard let defaults else { return }
        var entries = loadAll(from: defaults)
        entries.append(entry)
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: pendingEntriesKey)
        }
    }

    /// Returns and clears all pending entries.
    static func consumeAll() -> [PendingVoiceTimeEntry] {
        guard let defaults else { return [] }
        let entries = loadAll(from: defaults)
        defaults.removeObject(forKey: pendingEntriesKey)
        return entries
    }

    private static func loadAll(from defaults: UserDefaults) -> [PendingVoiceTimeEntry] {
        guard let data = defaults.data(forKey: pendingEntriesKey),
              let entries = try? JSONDecoder().decode([PendingVoiceTimeEntry].self, from: data)
        else {
            return []
        }
        return entries
    }
}

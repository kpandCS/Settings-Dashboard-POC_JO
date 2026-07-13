import AppIntents

/// Registers phrases so Siri (and Spotlight / the Shortcuts app) know to
/// route natural-language voice commands to `LogTimeIntent`.
@available(iOS 16.0, *)
struct PocketLinkShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogTimeIntent(),
            phrases: [
                "Log \(\.$hours) hours on \(\.$project) for \(\.$activity) in \(.applicationName)",
                "Log \(\.$hours) hours for \(\.$activity) on \(\.$project) in \(.applicationName)",
                "Register work time in \(.applicationName)",
                "Log time in \(.applicationName)",
            ],
            shortTitle: "Log Work Time",
            systemImageName: "mic.fill"
        )
    }
}

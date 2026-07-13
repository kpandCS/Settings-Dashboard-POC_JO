import AppIntents
import Foundation

/// The intent Siri invokes for "Log 2 hours on Strand Bolig for concrete
/// work in PocketLink". It never needs the app to be foregrounded: it just
/// appends to `VoiceTimeEntryStore`, and the Flutter side picks the entry up
/// the next time it launches or resumes (see AppDelegate + main.dart).
@available(iOS 16.0, *)
struct LogTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Work Time"
    static var description = IntentDescription(
        "Log hours worked on a project and activity in PocketLink."
    )

    @Parameter(title: "Hours")
    var hours: Double

    @Parameter(title: "Project")
    var project: PocketLinkProject

    @Parameter(title: "Activity")
    var activity: PocketLinkActivity

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$hours) hours on \(\.$project) for \(\.$activity)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let entry = VoiceTimeEntryStore.PendingVoiceTimeEntry(
            id: UUID().uuidString,
            projectName: project.displayName,
            activityName: activity.displayName,
            hours: hours,
            loggedAt: Date()
        )
        VoiceTimeEntryStore.appendEntry(entry)

        let hoursLabel = hours.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", hours)
            : String(format: "%.1f", hours)
        return .result(
            dialog: "Logged \(hoursLabel) hours on \(project.displayName) for \(activity.displayName)."
        )
    }
}

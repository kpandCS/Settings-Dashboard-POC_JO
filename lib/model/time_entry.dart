/// Where a logged time entry originated from.
enum TimeEntrySource { voiceInApp, siri, manual }

/// A single "I worked N hours on project X doing activity Y" record,
/// produced either by the in-app mic, by Siri (via App Intents), or by hand.
class TimeEntry {
  final String id;
  final String projectName;
  final String activityName;
  final double hours;
  final DateTime loggedAt;
  final TimeEntrySource source;

  const TimeEntry({
    required this.id,
    required this.projectName,
    required this.activityName,
    required this.hours,
    required this.loggedAt,
    required this.source,
  });
}

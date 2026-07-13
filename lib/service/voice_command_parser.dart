import '../model/activity.dart';
import '../model/project.dart';

/// Result of parsing a free-form voice/text command such as
/// "Log 2.5 hours on Strand Bolig for concrete work".
class VoiceParseResult {
  final String rawText;
  final double? hours;
  final Project? project;
  final Activity? activity;

  const VoiceParseResult({
    required this.rawText,
    this.hours,
    this.project,
    this.activity,
  });

  bool get isComplete => hours != null && hours! > 0 && project != null && activity != null;

  VoiceParseResult copyWith({double? hours, Project? project, Activity? activity}) {
    return VoiceParseResult(
      rawText: rawText,
      hours: hours ?? this.hours,
      project: project ?? this.project,
      activity: activity ?? this.activity,
    );
  }
}

/// Best-effort parser matching a spoken/typed command against the known
/// project and activity names. There's no NLP backend here — it extracts a
/// number of hours via regex and picks whichever project/activity name has
/// the most word-overlap with the transcript.
class VoiceCommandParser {
  VoiceCommandParser._();

  static final RegExp _hoursPattern = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(?:hours?|hrs?|timer)\b',
    caseSensitive: false,
  );

  static VoiceParseResult parse(
    String text, {
    List<Project>? projects,
    List<Activity>? activities,
  }) {
    final normalized = text.trim();
    return VoiceParseResult(
      rawText: normalized,
      hours: _extractHours(normalized),
      project: _bestMatch(normalized, projects ?? Project.mockProjects(), (p) => p.name),
      activity: _bestMatch(normalized, activities ?? Activity.mockActivities(), (a) => a.name),
    );
  }

  static double? _extractHours(String text) {
    final match = _hoursPattern.firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  static T? _bestMatch<T>(String text, List<T> items, String Function(T) nameOf) {
    final lower = text.toLowerCase();
    T? best;
    var bestScore = 0;
    for (final item in items) {
      final words = nameOf(item).toLowerCase().split(RegExp(r'\s+'));
      final score = words.where((w) => w.isNotEmpty && lower.contains(w)).length;
      if (score > bestScore) {
        bestScore = score;
        best = item;
      }
    }
    return bestScore > 0 ? best : null;
  }
}

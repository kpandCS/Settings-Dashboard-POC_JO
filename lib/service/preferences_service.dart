import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_preferences.dart';

/// Handles all SharedPreferences reads and writes.
/// This is the only class that knows about storage keys.
class PreferencesService {
  static const _kManualProjectId = 'pref_manual_project_id';
  static const _kManualProjectName = 'pref_manual_project_name';
  static const _kManualActivityId = 'pref_manual_activity_id';
  static const _kManualActivityName = 'pref_manual_activity_name';
  static const _kManualStartTime = 'pref_manual_start_time';
  static const _kNotifyDaily = 'pref_notify_daily';
  static const _kNotifyDeadlines = 'pref_notify_deadlines';
  static const _kAiAutoFill = 'pref_ai_autofill';
  static const _kAiPhoto = 'pref_ai_photo';
  static const _kLanguage = 'pref_language';
  static const _kUsageEventCount = 'pref_usage_event_count';

  // Simulated learned values (in production these come from usage history)
  static const _kLearnedProjectId = 'pref_learned_project_id';
  static const _kLearnedProjectName = 'pref_learned_project_name';
  static const _kLearnedActivityId = 'pref_learned_activity_id';
  static const _kLearnedActivityName = 'pref_learned_activity_name';
  static const _kLearnedStartTime = 'pref_learned_start_time';

  Future<UserPreferences> load() async {
    final p = await SharedPreferences.getInstance();
    return UserPreferences(
      learnedProjectId: p.getInt(_kLearnedProjectId),
      learnedProjectName: p.getString(_kLearnedProjectName),
      learnedActivityId: p.getInt(_kLearnedActivityId),
      learnedActivityName: p.getString(_kLearnedActivityName),
      learnedWorkStartTime: p.getString(_kLearnedStartTime),
      manualProjectId: p.getInt(_kManualProjectId),
      manualProjectName: p.getString(_kManualProjectName),
      manualActivityId: p.getInt(_kManualActivityId),
      manualActivityName: p.getString(_kManualActivityName),
      manualWorkStartTime: p.getString(_kManualStartTime),
      notifyDailyHours: p.getBool(_kNotifyDaily) ?? false,
      notifyDeadlines: p.getBool(_kNotifyDeadlines) ?? false,
      aiAutoFill: p.getBool(_kAiAutoFill) ?? true,
      aiPhotoAnalysis: p.getBool(_kAiPhoto) ?? true,
      language: p.getString(_kLanguage) ?? 'nb',
      usageEventCount: p.getInt(_kUsageEventCount) ?? 0,
    );
  }

  Future<void> saveManualDefaults({
    int? projectId,
    String? projectName,
    int? activityId,
    String? activityName,
    String? workStartTime,
  }) async {
    final p = await SharedPreferences.getInstance();
    if (projectId != null) {
      await p.setInt(_kManualProjectId, projectId);
      await p.setString(_kManualProjectName, projectName ?? '');
    } else {
      await p.remove(_kManualProjectId);
      await p.remove(_kManualProjectName);
    }
    if (activityId != null) {
      await p.setInt(_kManualActivityId, activityId);
      await p.setString(_kManualActivityName, activityName ?? '');
    } else {
      await p.remove(_kManualActivityId);
      await p.remove(_kManualActivityName);
    }
    if (workStartTime != null) {
      await p.setString(_kManualStartTime, workStartTime);
    } else {
      await p.remove(_kManualStartTime);
    }
  }

  Future<void> clearManualDefaults() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kManualProjectId);
    await p.remove(_kManualProjectName);
    await p.remove(_kManualActivityId);
    await p.remove(_kManualActivityName);
    await p.remove(_kManualStartTime);
  }

  /// Full reset — removes learned defaults, manual defaults, and the
  /// usage event counter so the learning progress bar restarts from zero.
  Future<void> clearAllDefaults() async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.remove(_kManualProjectId),
      p.remove(_kManualProjectName),
      p.remove(_kManualActivityId),
      p.remove(_kManualActivityName),
      p.remove(_kManualStartTime),
      p.remove(_kLearnedProjectId),
      p.remove(_kLearnedProjectName),
      p.remove(_kLearnedActivityId),
      p.remove(_kLearnedActivityName),
      p.remove(_kLearnedStartTime),
      p.remove(_kUsageEventCount),
    ]);
  }

  Future<void> saveToggle(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
  }

  Future<void> saveLanguage(String lang) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLanguage, lang);
  }

  /// Simulate recording a usage event and deriving learned defaults.
  /// In production, this would parse the full event log.
  Future<void> recordUsageAndLearn({
    required int projectId,
    required String projectName,
    required int activityId,
    required String activityName,
  }) async {
    final p = await SharedPreferences.getInstance();
    final count = (p.getInt(_kUsageEventCount) ?? 0) + 1;
    await p.setInt(_kUsageEventCount, count);

    // After 5 events, persist learned defaults
    if (count >= UserPreferences.requiredEvents) {
      await p.setInt(_kLearnedProjectId, projectId);
      await p.setString(_kLearnedProjectName, projectName);
      await p.setInt(_kLearnedActivityId, activityId);
      await p.setString(_kLearnedActivityName, activityName);
      await p.setString(_kLearnedStartTime, '07:00');
    }
  }

  // Exposed key names for toggles (used by ViewModel)
  static const notifyDailyKey = _kNotifyDaily;
  static const notifyDeadlinesKey = _kNotifyDeadlines;
  static const aiAutoFillKey = _kAiAutoFill;
  static const aiPhotoKey = _kAiPhoto;
}

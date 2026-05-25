/// Holds both learned (usage-derived) and manually-set user preferences.
/// Manual values always take priority over learned values.
class UserPreferences {
  // ── Learned from usage history ────────────────────────────────────
  final int? learnedProjectId;
  final String? learnedProjectName;
  final int? learnedActivityId;
  final String? learnedActivityName;
  final String? learnedWorkStartTime; // "07:00"

  // ── Manually set by the worker ────────────────────────────────────
  final int? manualProjectId;
  final String? manualProjectName;
  final int? manualActivityId;
  final String? manualActivityName;
  final String? manualWorkStartTime;

  // ── Feature toggles ───────────────────────────────────────────────
  final bool notifyDailyHours;
  final bool notifyDeadlines;
  final bool aiAutoFill;
  final bool aiPhotoAnalysis;
  final String language; // "nb" or "en"

  // ── Learning progress ─────────────────────────────────────────────
  final int usageEventCount;
  static const int requiredEvents = 5;

  const UserPreferences({
    this.learnedProjectId,
    this.learnedProjectName,
    this.learnedActivityId,
    this.learnedActivityName,
    this.learnedWorkStartTime,
    this.manualProjectId,
    this.manualProjectName,
    this.manualActivityId,
    this.manualActivityName,
    this.manualWorkStartTime,
    this.notifyDailyHours = false,
    this.notifyDeadlines = false,
    this.aiAutoFill = true,
    this.aiPhotoAnalysis = true,
    this.language = 'nb',
    this.usageEventCount = 0,
  });

  // ── Effective getters: manual takes priority over learned ─────────
  int? get effectiveProjectId => manualProjectId ?? learnedProjectId;
  String? get effectiveProjectName => manualProjectName ?? learnedProjectName;
  int? get effectiveActivityId => manualActivityId ?? learnedActivityId;
  String? get effectiveActivityName =>
      manualActivityName ?? learnedActivityName;
  String? get effectiveWorkStartTime =>
      manualWorkStartTime ?? learnedWorkStartTime;

  // ── UI helpers ────────────────────────────────────────────────────
  bool get hasEnoughDataToLearn => usageEventCount >= requiredEvents;
  bool get hasAnyDefault =>
      effectiveProjectId != null || effectiveActivityId != null;

  // Whether each effective value came from manual input (vs learned)
  bool get projectIsManual => manualProjectId != null;
  bool get activityIsManual => manualActivityId != null;
  bool get startTimeIsManual => manualWorkStartTime != null;

  int get eventsUntilReady =>
      (requiredEvents - usageEventCount).clamp(0, requiredEvents);
  double get learningProgress =>
      (usageEventCount / requiredEvents).clamp(0.0, 1.0);

  String get languageLabel => language == 'nb' ? 'Norwegian Bokmål' : 'English';

  UserPreferences copyWith({
    int? learnedProjectId,
    String? learnedProjectName,
    int? learnedActivityId,
    String? learnedActivityName,
    String? learnedWorkStartTime,
    int? manualProjectId,
    String? manualProjectName,
    int? manualActivityId,
    String? manualActivityName,
    String? manualWorkStartTime,
    bool? notifyDailyHours,
    bool? notifyDeadlines,
    bool? aiAutoFill,
    bool? aiPhotoAnalysis,
    String? language,
    int? usageEventCount,
    // clear flags for manual values
    bool clearManualProject = false,
    bool clearManualActivity = false,
    bool clearManualStartTime = false,
    // clear flags for learned values
    bool clearLearnedProject = false,
    bool clearLearnedActivity = false,
    bool clearLearnedStartTime = false,
  }) {
    return UserPreferences(
      learnedProjectId: clearLearnedProject
          ? null
          : (learnedProjectId ?? this.learnedProjectId),
      learnedProjectName: clearLearnedProject
          ? null
          : (learnedProjectName ?? this.learnedProjectName),
      learnedActivityId: clearLearnedActivity
          ? null
          : (learnedActivityId ?? this.learnedActivityId),
      learnedActivityName: clearLearnedActivity
          ? null
          : (learnedActivityName ?? this.learnedActivityName),
      learnedWorkStartTime: clearLearnedStartTime
          ? null
          : (learnedWorkStartTime ?? this.learnedWorkStartTime),
      manualProjectId:
          clearManualProject ? null : (manualProjectId ?? this.manualProjectId),
      manualProjectName: clearManualProject
          ? null
          : (manualProjectName ?? this.manualProjectName),
      manualActivityId: clearManualActivity
          ? null
          : (manualActivityId ?? this.manualActivityId),
      manualActivityName: clearManualActivity
          ? null
          : (manualActivityName ?? this.manualActivityName),
      manualWorkStartTime: clearManualStartTime
          ? null
          : (manualWorkStartTime ?? this.manualWorkStartTime),
      notifyDailyHours: notifyDailyHours ?? this.notifyDailyHours,
      notifyDeadlines: notifyDeadlines ?? this.notifyDeadlines,
      aiAutoFill: aiAutoFill ?? this.aiAutoFill,
      aiPhotoAnalysis: aiPhotoAnalysis ?? this.aiPhotoAnalysis,
      language: language ?? this.language,
      usageEventCount: usageEventCount ?? this.usageEventCount,
    );
  }
}

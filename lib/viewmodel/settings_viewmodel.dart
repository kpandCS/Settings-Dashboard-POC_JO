import 'package:flutter/material.dart';
import '../model/user_preferences.dart';
import '../service/preferences_service.dart';

enum SettingsLoadState { loading, ready, error }

/// ViewModel for the Settings screen.
/// Holds all state, exposes actions, notifies the View on change.
/// The View never touches PreferencesService directly.
class SettingsViewModel extends ChangeNotifier {
  final PreferencesService _service;

  SettingsViewModel({PreferencesService? service})
      : _service = service ?? PreferencesService() {
    load();
  }

  // ── State ─────────────────────────────────────────────────────────
  SettingsLoadState _loadState = SettingsLoadState.loading;
  UserPreferences _prefs = const UserPreferences();
  String? _errorMessage;
  String? _snackMessage;

  // ── Getters (View reads these) ────────────────────────────────────
  SettingsLoadState get loadState => _loadState;
  UserPreferences get prefs => _prefs;
  String? get errorMessage => _errorMessage;

  String? get snackMessage {
    final msg = _snackMessage;
    _snackMessage = null; // consume once
    return msg;
  }

  bool get isLoading => _loadState == SettingsLoadState.loading;

  // ── Actions ───────────────────────────────────────────────────────
  Future<void> load() async {
    _loadState = SettingsLoadState.loading;
    notifyListeners();
    try {
      _prefs = await _service.load();
      _loadState = SettingsLoadState.ready;
    } catch (e) {
      _errorMessage = 'Failed to load settings.';
      _loadState = SettingsLoadState.error;
    }
    notifyListeners();
  }

  Future<void> saveManualDefaults({
    int? projectId,
    String? projectName,
    int? activityId,
    String? activityName,
    String? workStartTime,
  }) async {
    await _service.saveManualDefaults(
      projectId: projectId,
      projectName: projectName,
      activityId: activityId,
      activityName: activityName,
      workStartTime: workStartTime,
    );
    // Update in-memory state immediately — no reload round-trip needed
    _prefs = _prefs.copyWith(
      manualProjectId: projectId,
      manualProjectName: projectName,
      manualActivityId: activityId,
      manualActivityName: activityName,
      manualWorkStartTime: workStartTime,
      clearManualProject: projectId == null,
      clearManualActivity: activityId == null,
      clearManualStartTime: workStartTime == null,
    );
    _snackMessage = 'Defaults saved';
    notifyListeners();
  }

  Future<void> clearManualDefaults() async {
    // Wipe everything — manual overrides, learned values, and the event
    // counter — so the UI returns cleanly to the "learning" empty state.
    await _service.clearAllDefaults();
    _prefs = _prefs.copyWith(
      clearManualProject: true,
      clearManualActivity: true,
      clearManualStartTime: true,
      clearLearnedProject: true,
      clearLearnedActivity: true,
      clearLearnedStartTime: true,
      usageEventCount: 0,
    );
    _snackMessage = 'Defaults reset';
    notifyListeners();
  }

  Future<void> toggleNotifyDailyHours(bool value) async {
    await _service.saveToggle(PreferencesService.notifyDailyKey, value);
    _prefs = _prefs.copyWith(notifyDailyHours: value);
    notifyListeners();
  }

  Future<void> toggleNotifyDeadlines(bool value) async {
    await _service.saveToggle(PreferencesService.notifyDeadlinesKey, value);
    _prefs = _prefs.copyWith(notifyDeadlines: value);
    notifyListeners();
  }

  Future<void> toggleAiAutoFill(bool value) async {
    await _service.saveToggle(PreferencesService.aiAutoFillKey, value);
    _prefs = _prefs.copyWith(aiAutoFill: value);
    notifyListeners();
  }

  Future<void> toggleAiPhotoAnalysis(bool value) async {
    await _service.saveToggle(PreferencesService.aiPhotoKey, value);
    _prefs = _prefs.copyWith(aiPhotoAnalysis: value);
    notifyListeners();
  }

  Future<void> changeLanguage(String lang) async {
    await _service.saveLanguage(lang);
    _prefs = _prefs.copyWith(language: lang);
    notifyListeners();
  }

  /// Simulate adding a work report (demonstrates the learning progress)
  Future<void> simulateWorkReportAdded() async {
    await _service.recordUsageAndLearn(
      projectId: 1,
      projectName: 'Strand Bolig',
      activityId: 1,
      activityName: 'Concrete work',
    );
    await load();
    _snackMessage = 'Work report recorded  (${_prefs.usageEventCount} of ${UserPreferences.requiredEvents})';
    notifyListeners();
  }
}

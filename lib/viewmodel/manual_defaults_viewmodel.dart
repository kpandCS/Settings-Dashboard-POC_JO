import 'package:flutter/material.dart';
import '../model/activity.dart';
import '../model/project.dart';
import '../model/user_preferences.dart';

enum ManualDefaultsState { idle, saving, saved }

/// ViewModel for the Manual Defaults bottom sheet.
/// Manages project search, selections, and save state independently
/// from the main SettingsViewModel.
class ManualDefaultsViewModel extends ChangeNotifier {
  ManualDefaultsViewModel({required UserPreferences initialPrefs}) {
    _selectedProjectId = initialPrefs.effectiveProjectId;
    _selectedProjectName = initialPrefs.effectiveProjectName;
    _selectedActivityId = initialPrefs.effectiveActivityId;
    _selectedActivityName = initialPrefs.effectiveActivityName;
    _selectedStartTime = initialPrefs.effectiveWorkStartTime;
    _allProjects = Project.mockProjects();
    _filteredProjects = _allProjects;
    _activities = Activity.mockActivities();
  }

  // ── State ─────────────────────────────────────────────────────────
  ManualDefaultsState _state = ManualDefaultsState.idle;
  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  List<Activity> _activities = [];
  String _searchQuery = '';

  int? _selectedProjectId;
  String? _selectedProjectName;
  int? _selectedActivityId;
  String? _selectedActivityName;
  String? _selectedStartTime;

  // ── Getters ───────────────────────────────────────────────────────
  ManualDefaultsState get state => _state;
  List<Project> get filteredProjects => _filteredProjects;
  List<Activity> get activities => _activities;
  String get searchQuery => _searchQuery;
  bool get isSaving => _state == ManualDefaultsState.saving;

  int? get selectedProjectId => _selectedProjectId;
  String? get selectedProjectName => _selectedProjectName;
  int? get selectedActivityId => _selectedActivityId;
  String? get selectedActivityName => _selectedActivityName;
  String? get selectedStartTime => _selectedStartTime;

  // ── Actions ───────────────────────────────────────────────────────
  void searchProjects(String query) {
    _searchQuery = query;
    _filteredProjects = query.isEmpty
        ? _allProjects
        : _allProjects
            .where(
              (p) => p.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    notifyListeners();
  }

  void selectProject(Project project) {
    _selectedProjectId = project.id;
    _selectedProjectName = project.name;
    notifyListeners();
  }

  void clearProject() {
    _selectedProjectId = null;
    _selectedProjectName = null;
    notifyListeners();
  }

  void selectActivity(Activity activity) {
    _selectedActivityId = activity.id;
    _selectedActivityName = activity.name;
    notifyListeners();
  }

  void clearActivity() {
    _selectedActivityId = null;
    _selectedActivityName = null;
    notifyListeners();
  }

  void selectStartTime(String time) {
    _selectedStartTime = time;
    notifyListeners();
  }

  void clearStartTime() {
    _selectedStartTime = null;
    notifyListeners();
  }

  void setSaving() {
    _state = ManualDefaultsState.saving;
    notifyListeners();
  }

  void setSaved() {
    _state = ManualDefaultsState.saved;
    notifyListeners();
  }
}

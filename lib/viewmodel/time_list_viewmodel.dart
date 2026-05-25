import 'package:flutter/material.dart';
import '../model/time_entry.dart';

/// ViewModel for the Time List — Intelligent Timesheet screen.
///
/// In production this calls:
///   GET /api/v1/workReport/hourlist/{employeeId}
/// and maps the JSON to [WeeklyTimesheet].
///
/// AI gap detection is purely client-side — no extra endpoint needed.
class TimeListViewModel extends ChangeNotifier {
  WeeklyTimesheet _sheet = WeeklyTimesheet.mock();
  bool _isLoading = false;
  bool _aiDismissed = false;
  int _weekOffset = 0; // 0 = current week, -1 = last week, etc.

  WeeklyTimesheet get sheet => _sheet;
  bool get isLoading => _isLoading;
  bool get showAiBanner => !_aiDismissed && _sheet.aiFlags.isNotEmpty;

  // ── Week navigation ───────────────────────────────────────────────────────

  void previousWeek() {
    _weekOffset--;
    _loadWeek();
  }

  void nextWeek() {
    if (_weekOffset >= 0) return; // can't go into future
    _weekOffset++;
    _loadWeek();
  }

  bool get canGoForward => _weekOffset < 0;

  // ── AI actions ────────────────────────────────────────────────────────────

  /// "Fill gaps" tapped — in production this would open a pre-filled
  /// WorkReport creation sheet for the flagged day.
  ///
  /// Suggested API call:
  ///   POST /api/v1/workReport  { employeeId, date, hoursLogged, projectId }
  void fillGap(DayEntry entry) {
    // TODO: open WorkReport sheet pre-filled with
    //   date = entry.date
    //   projectId = entry from similar recent WR
    //   hoursLogged = entry.dailyTarget (suggested)
    notifyListeners();
  }

  /// Copy yesterday's hours to a flagged day.
  ///
  /// Suggested API call:
  ///   POST /api/v1/workReport/copy  { sourceDate, targetDate, employeeId }
  void copyYesterdayHours(DayEntry entry) {
    // TODO: call copy API then reload
    notifyListeners();
  }

  void dismissAiBanner() {
    _aiDismissed = true;
    notifyListeners();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadWeek() async {
    _isLoading = true;
    _aiDismissed = false;
    notifyListeners();

    // Simulate network delay.
    // In production:
    //   final response = await _apiClient.get(
    //     '/api/v1/workReport/hourlist/$employeeId',
    //     queryParams: { 'weekOffset': _weekOffset },
    //   );
    //   _sheet = WeeklyTimesheet.fromJson(response.data);
    await Future.delayed(const Duration(milliseconds: 600));
    _sheet = WeeklyTimesheet.mock();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _loadWeek();
}

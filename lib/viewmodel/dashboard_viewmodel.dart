import 'package:flutter/material.dart';
import '../model/dashboard_data.dart';
import '../model/time_entry.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardData _data = DashboardData.mock();
  bool _isRefreshing = false;

  DashboardData get data => _data;
  bool get isRefreshing => _isRefreshing;

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    _data = DashboardData.mock();
    _isRefreshing = false;
    notifyListeners();
  }

  /// Folds a voice-logged (in-app mic or Siri) time entry into today's
  /// dashboard data: bumps hours-today, the matching active project's
  /// totals, and surfaces it as a new pending report awaiting signature.
  void applyTimeEntry(TimeEntry entry) {
    final updatedProjects = _data.activeProjects.map((p) {
      if (p.name.toLowerCase() != entry.projectName.toLowerCase()) return p;
      return ActiveProjectSummary(
        id: p.id,
        name: p.name,
        status: p.status,
        totalHours: p.totalHours + entry.hours,
        workReportCount: p.workReportCount + 1,
      );
    }).toList();

    final newReport = PendingWorkReport(
      id: 'V-${entry.id.length > 6 ? entry.id.substring(entry.id.length - 6) : entry.id}',
      projectName: entry.projectName,
      date: _formatLogTime(entry.loggedAt),
      hoursLogged: entry.hours,
      materialsCount: 0,
    );

    _data = DashboardData(
      hoursToday: _data.hoursToday + entry.hours,
      dailyTarget: _data.dailyTarget,
      photosUploadedToday: _data.photosUploadedToday,
      pendingReports: [newReport, ..._data.pendingReports],
      activeProjects: updatedProjects,
      recentPhotos: _data.recentPhotos,
      myLicense: _data.myLicense,
    );
    notifyListeners();
  }

  String _formatLogTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return 'Today, $hh:$mm';
  }
}

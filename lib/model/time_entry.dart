// ── Time List — Intelligent Timesheet Model ───────────────────────────────────
//
// Production API:  GET /api/v1/workReport/hourlist/{employeeId}
// Response shape (abridged):
// {
//   "employeeId": "string",
//   "weekStart": "2025-05-19T00:00:00Z",
//   "weeklyTargetHours": 40.0,
//   "entries": [
//     {
//       "date": "2025-05-19T00:00:00Z",
//       "hoursLogged": 8.0,
//       "projectId": 1,
//       "projectName": "Strand Bolig",
//       "workReportId": "WR-2041",   // null if no WR exists
//       "workReportStatus": "Signed" // Signed | Pending | null
//     },
//     ...
//   ]
// }
//
// AI gap detection runs entirely client-side — no new endpoint needed.

enum EntryStatus {
  /// Hours logged and work report signed — all good.
  logged,

  /// Work report EXISTS for this day but hoursLogged == 0.
  /// AI flags this as "open report without hour entry".
  workReportNoHours,

  /// No work report and no hours for a working day.
  /// AI flags this as a missing entry.
  gap,

  /// Saturday / Sunday — not expected to work.
  weekend,
}

class DayEntry {
  final DateTime date;
  final double hoursLogged;
  final double dailyTarget; // typically 8.0h
  final String? projectName;
  final String? workReportId;
  final String? workReportStatus; // "Signed" | "Pending" | null
  final EntryStatus status;

  const DayEntry({
    required this.date,
    required this.hoursLogged,
    required this.dailyTarget,
    this.projectName,
    this.workReportId,
    this.workReportStatus,
    required this.status,
  });

  /// Progress 0.0–1.0 for the bar indicator.
  double get progress => dailyTarget > 0
      ? (hoursLogged / dailyTarget).clamp(0.0, 1.0)
      : 0.0;

  bool get isGap =>
      status == EntryStatus.gap || status == EntryStatus.workReportNoHours;
}

class WeeklyTimesheet {
  final DateTime weekStart;
  final double weeklyTarget; // e.g. 40.0
  final List<DayEntry> entries; // Mon → Sun (7 items)
  final String employeeId;
  final String employeeName;

  const WeeklyTimesheet({
    required this.weekStart,
    required this.weeklyTarget,
    required this.entries,
    required this.employeeId,
    required this.employeeName,
  });

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  // ── AI-computed summaries ─────────────────────────────────────────────────
  double get totalLogged =>
      entries.fold(0.0, (sum, e) => sum + e.hoursLogged);

  double get hoursRemaining =>
      (weeklyTarget - totalLogged).clamp(0.0, weeklyTarget);

  double get progressFraction =>
      (totalLogged / weeklyTarget).clamp(0.0, 1.0);

  List<DayEntry> get gaps =>
      entries.where((e) => e.status == EntryStatus.gap).toList();

  List<DayEntry> get reportsWithNoHours =>
      entries.where((e) => e.status == EntryStatus.workReportNoHours).toList();

  List<DayEntry> get aiFlags =>
      entries.where((e) => e.isGap).toList();

  bool get hasOvertimeRisk {
    // Flag if pace through mid-week projects > 42h by Friday
    final workDaysElapsed =
        entries.where((e) => e.status == EntryStatus.logged).length;
    if (workDaysElapsed < 3) return false;
    final pace = totalLogged / workDaysElapsed;
    return pace * 5 > 42;
  }

  // ── Mock data — week of 19–25 May 2025 ───────────────────────────────────
  // Mirrors what GET /api/v1/workReport/hourlist/{employeeId} would return.
  static WeeklyTimesheet mock() {
    final weekStart = DateTime(2025, 5, 19); // Monday
    return WeeklyTimesheet(
      weekStart: weekStart,
      weeklyTarget: 40.0,
      employeeId: 'emp-001',
      employeeName: 'Kari Pedersen',
      entries: [
        DayEntry(
          date: weekStart,
          hoursLogged: 8.0,
          dailyTarget: 8.0,
          projectName: 'Strand Bolig',
          workReportId: 'WR-2038',
          workReportStatus: 'Signed',
          status: EntryStatus.logged,
        ),
        DayEntry(
          date: weekStart.add(const Duration(days: 1)),
          hoursLogged: 7.5,
          dailyTarget: 8.0,
          projectName: 'Bergkvist Bolig',
          workReportId: 'WR-2039',
          workReportStatus: 'Signed',
          status: EntryStatus.logged,
        ),
        DayEntry(
          date: weekStart.add(const Duration(days: 2)),
          hoursLogged: 6.0,
          dailyTarget: 8.0,
          projectName: 'Bergkvist Bolig',
          workReportId: 'WR-2040',
          workReportStatus: 'Pending',
          status: EntryStatus.logged,
        ),
        // ── AI flagged: WR exists but no hours entered ───────────────────
        DayEntry(
          date: weekStart.add(const Duration(days: 3)),
          hoursLogged: 0.0,
          dailyTarget: 8.0,
          projectName: 'Lofoten Hytte',
          workReportId: 'WR-2041',      // WR exists!
          workReportStatus: 'Pending',
          status: EntryStatus.workReportNoHours,
        ),
        // ── AI flagged: no WR, no hours ──────────────────────────────────
        DayEntry(
          date: weekStart.add(const Duration(days: 4)),
          hoursLogged: 0.0,
          dailyTarget: 8.0,
          projectName: null,
          workReportId: null,
          workReportStatus: null,
          status: EntryStatus.gap,
        ),
        DayEntry(
          date: weekStart.add(const Duration(days: 5)),
          hoursLogged: 0.0,
          dailyTarget: 0.0,
          status: EntryStatus.weekend,
        ),
        DayEntry(
          date: weekStart.add(const Duration(days: 6)),
          hoursLogged: 0.0,
          dailyTarget: 0.0,
          status: EntryStatus.weekend,
        ),
      ],
    );
  }
}

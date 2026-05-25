import 'license_data.dart';

class PendingWorkReport {
  final String id;
  final String projectName;
  final String date;
  final double hoursLogged;
  final int materialsCount;

  const PendingWorkReport({
    required this.id,
    required this.projectName,
    required this.date,
    required this.hoursLogged,
    required this.materialsCount,
  });
}

class ActiveProjectSummary {
  final int id;
  final String name;
  final String status;
  final double totalHours;
  final int workReportCount;

  const ActiveProjectSummary({
    required this.id,
    required this.name,
    required this.status,
    required this.totalHours,
    required this.workReportCount,
  });
}

class RecentPhoto {
  final String id;
  final String projectName;
  final String timeAgo;

  const RecentPhoto({
    required this.id,
    required this.projectName,
    required this.timeAgo,
  });
}

class DashboardData {
  final double hoursToday;
  final double dailyTarget;
  final int photosUploadedToday;
  final List<PendingWorkReport> pendingReports;
  final List<ActiveProjectSummary> activeProjects;
  final List<RecentPhoto> recentPhotos;
  /// License status for the currently authenticated user only.
  final UserLicenseStatus myLicense;

  const DashboardData({
    required this.hoursToday,
    required this.dailyTarget,
    required this.photosUploadedToday,
    required this.pendingReports,
    required this.activeProjects,
    required this.recentPhotos,
    required this.myLicense,
  });

  int get activeProjectsCount => activeProjects.length;
  int get pendingSignaturesCount => pendingReports.length;
  double get hoursProgress => (hoursToday / dailyTarget).clamp(0.0, 1.0);
  double get hoursRemaining => (dailyTarget - hoursToday).clamp(0.0, dailyTarget);

  static DashboardData mock() => DashboardData(
        hoursToday: 4.5,
        dailyTarget: 7.5,
        photosUploadedToday: 3,
        myLicense: HoletportalenLicenseData.mockCurrentUser(),
        pendingReports: [
          PendingWorkReport(
            id: 'WR-2041',
            projectName: 'Strand Bolig',
            date: 'Today, 09:14',
            hoursLogged: 2.5,
            materialsCount: 4,
          ),
          PendingWorkReport(
            id: 'WR-2039',
            projectName: 'Lofoten Hytte',
            date: 'Today, 07:30',
            hoursLogged: 2.0,
            materialsCount: 2,
          ),
        ],
        activeProjects: [
          ActiveProjectSummary(
            id: 1,
            name: 'Strand Bolig',
            status: 'Under Arbeid',
            totalHours: 38.5,
            workReportCount: 12,
          ),
          ActiveProjectSummary(
            id: 2,
            name: 'Bergkvist Bolig',
            status: 'Under Arbeid',
            totalHours: 21.0,
            workReportCount: 7,
          ),
          ActiveProjectSummary(
            id: 4,
            name: 'Lofoten Hytte',
            status: 'Under Arbeid',
            totalHours: 14.0,
            workReportCount: 5,
          ),
          ActiveProjectSummary(
            id: 7,
            name: 'Stavanger Kontor',
            status: 'Under Arbeid',
            totalHours: 6.5,
            workReportCount: 2,
          ),
        ],
        recentPhotos: [
          RecentPhoto(id: 'p1', projectName: 'Strand Bolig', timeAgo: '2h ago'),
          RecentPhoto(id: 'p2', projectName: 'Strand Bolig', timeAgo: '2h ago'),
          RecentPhoto(id: 'p3', projectName: 'Lofoten Hytte', timeAgo: '4h ago'),
        ],
      );
}

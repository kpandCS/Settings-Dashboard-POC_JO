import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../model/agenda_item.dart';
import '../../viewmodel/dashboard_viewmodel.dart';
import '../widgets/dashboard/active_projects_card.dart';
import '../widgets/dashboard/hours_card.dart';
import '../widgets/dashboard/pending_reports_card.dart';
import '../widgets/dashboard/recent_photos_card.dart';
import '../widgets/dashboard/stat_tile.dart';
import '../widgets/settings/agenda_card.dart';
import '../widgets/settings/settings_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.surfaceContainer,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceContainer,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('My Day'),
                Text(
                  _todayLabel(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: Icon(
                  PhosphorIcons.arrowClockwise(PhosphorIconsStyle.regular),
                  size: 22,
                ),
                onPressed: vm.isRefreshing ? null : vm.refresh,
              ),
            ],
          ),
          body: vm.isRefreshing
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: vm.refresh,
                  color: AppColors.brandOrange,
                  child: ListView(
                    // bottom: 80 NavigationBar + 24 breathing room
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
                    children: [
                      // ── Agenda for Today — always first ────────────
                      const _SectionLabel('Agenda for Today'),
                      AgendaCard(items: AgendaItem.mockToday()),
                      const SizedBox(height: 24),

                      // ── Hours progress ─────────────────────────────
                      HoursCard(data: vm.data),
                      const SizedBox(height: 12),

                      // ── KPI tiles ──────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              icon: PhosphorIcons.hardHat(
                                  PhosphorIconsStyle.fill),
                              value: '${vm.data.activeProjectsCount}',
                              label: 'Active Projects',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatTile(
                              icon: PhosphorIcons.pencilSimple(
                                  PhosphorIconsStyle.fill),
                              value: '${vm.data.pendingSignaturesCount}',
                              label: 'Pending Signatures',
                              iconColor: vm.data.pendingSignaturesCount > 0
                                  ? AppColors.errorRed
                                  : AppColors.successGreen,
                              iconBackground:
                                  vm.data.pendingSignaturesCount > 0
                                      ? AppColors.errorRed.withValues(alpha: 0.12)
                                      : AppColors.lightGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Quick actions ──────────────────────────────
                      const _SectionLabel('Quick Actions'),
                      SettingsCard(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () {},
                                    icon: Icon(
                                      PhosphorIcons.plus(
                                          PhosphorIconsStyle.bold),
                                      size: 16,
                                    ),
                                    label: const Text('Work Report'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: Icon(
                                      PhosphorIcons.camera(
                                          PhosphorIconsStyle.regular),
                                      size: 16,
                                    ),
                                    label: const Text('Photos'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Pending signatures ─────────────────────────
                      const _SectionLabel('Pending Signatures'),
                      PendingReportsCard(reports: vm.data.pendingReports),
                      const SizedBox(height: 24),

                      // ── Active projects ────────────────────────────
                      const _SectionLabel('Active Projects'),
                      ActiveProjectsCard(projects: vm.data.activeProjects),
                      const SizedBox(height: 24),

                      // ── Recent photos ──────────────────────────────
                      const _SectionLabel('Photos Today'),
                      RecentPhotosCard(
                        photos: vm.data.recentPhotos,
                        totalToday: vm.data.photosUploadedToday,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../model/time_entry.dart';
import '../../viewmodel/time_list_viewmodel.dart';
import '../widgets/timelist/ai_insight_banner.dart';
import '../widgets/timelist/day_entry_row.dart';
import '../widgets/timelist/week_navigator.dart';

/// Time List — Intelligent Timesheet screen.
///
/// Assembles:
///   • WeekNavigator  — week selector row with progress bar
///   • AiInsightBanner — collapsible AI warning (shown when gaps exist)
///   • DayEntryRow × 7 — Mon–Sun with per-day progress bars
///   • Overtime risk banner (when pace > 42 h/week projection)
///
/// Production data source:
///   GET /api/v1/workReport/hourlist/{employeeId}?weekOffset=N
class TimeListScreen extends StatelessWidget {
  const TimeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimeListViewModel(),
      child: const _TimeListView(),
    );
  }
}

class _TimeListView extends StatelessWidget {
  const _TimeListView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimeListViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainer,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandOrange,
          onRefresh: vm.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── App bar ───────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppColors.surfaceBase,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  'Time List',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: vm.refresh,
                    icon: Icon(
                      PhosphorIcons.arrowClockwise(PhosphorIconsStyle.bold),
                      color: AppColors.brandOrange,
                    ),
                  ),
                ],
              ),

              // ── Loading indicator ─────────────────────────────────────
              if (vm.isLoading)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                    color: AppColors.brandOrange,
                  ),
                ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Week navigator ──────────────────────────────────
                    WeekNavigator(
                      sheet: vm.sheet,
                      canGoForward: vm.canGoForward,
                      onPrevious: vm.previousWeek,
                      onNext: vm.nextWeek,
                    ),

                    const SizedBox(height: 12),

                    // ── AI insight banner ───────────────────────────────
                    if (vm.showAiBanner) ...[
                      AiInsightBanner(
                        sheet: vm.sheet,
                        onFillGap: vm.fillGap,
                        onCopyYesterday: vm.copyYesterdayHours,
                        onDismiss: vm.dismissAiBanner,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Overtime risk banner ────────────────────────────
                    if (vm.sheet.hasOvertimeRisk) ...[
                      _OvertimeBanner(theme: theme),
                      const SizedBox(height: 12),
                    ],

                    // ── Daily breakdown card ────────────────────────────
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section header
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.calendarBlank(
                                      PhosphorIconsStyle.fill),
                                  size: 16,
                                  color: AppColors.brandOrange,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Daily Breakdown',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),
                            const Divider(
                                height: 16, color: AppColors.outlineVariant),

                            // Day rows
                            ...vm.sheet.entries.map(
                              (e) => DayEntryRow(entry: e),
                            ),

                            const SizedBox(height: 6),
                            const Divider(
                                height: 1, color: AppColors.outlineVariant),
                            const SizedBox(height: 10),

                            // Week total footer
                            _WeekTotalsRow(sheet: vm.sheet, theme: theme),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── API note (dev hint) ─────────────────────────────
                    _ApiHint(theme: theme),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Overtime risk banner ───────────────────────────────────────────────────────
class _OvertimeBanner extends StatelessWidget {
  final ThemeData theme;
  const _OvertimeBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF8E1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: const BorderSide(color: Color(0xFFFFB300), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.clock(PhosphorIconsStyle.fill),
              size: 18,
              color: const Color(0xFFE65100),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Overtime risk — at your current pace you may exceed '
                '42 h by Friday.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5D3A00),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Week totals footer row ─────────────────────────────────────────────────────
class _WeekTotalsRow extends StatelessWidget {
  final WeeklyTimesheet sheet;
  final ThemeData theme;

  const _WeekTotalsRow({required this.sheet, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isComplete = sheet.hoursRemaining == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Weekly total',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        RichText(
          text: TextSpan(
            style: theme.textTheme.labelMedium,
            children: [
              TextSpan(
                text: '${sheet.totalLogged.toStringAsFixed(1)} h',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color:
                      isComplete ? AppColors.successGreen : AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: ' / ${sheet.weeklyTarget.toStringAsFixed(0)} h',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (!isComplete)
                TextSpan(
                  text: '  (${sheet.hoursRemaining.toStringAsFixed(1)} h remaining)',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Developer / integration hint ──────────────────────────────────────────────
class _ApiHint extends StatelessWidget {
  final ThemeData theme;
  const _ApiHint({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIcons.code(PhosphorIconsStyle.bold),
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'API: GET /api/v1/workReport/hourlist/{employeeId}'
              '?weekOffset=N\n'
              'AI gap detection is purely client-side — no extra endpoint needed.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

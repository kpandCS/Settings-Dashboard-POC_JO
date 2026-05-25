import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../model/time_entry.dart';

/// AI-generated insight banner shown at the top of the time list when the
/// employee has unfilled gaps in the current week.
///
/// ┌──────────────────────────────────────────────────────────────┐
/// │ ⚠  AI Insight                                          [✕]  │
/// │ You are 18.5 h short of your 40 h weekly target.            │
/// │                                                              │
/// │  • Thursday — open work report with no hours logged          │
/// │  • Friday — no work report recorded                          │
/// │                                                              │
/// │  [Fill Thursday]  [Fill Friday]               [Dismiss]      │
/// └──────────────────────────────────────────────────────────────┘
class AiInsightBanner extends StatelessWidget {
  final WeeklyTimesheet sheet;
  final void Function(DayEntry) onFillGap;
  final void Function(DayEntry) onCopyYesterday;
  final VoidCallback onDismiss;

  const AiInsightBanner({
    super.key,
    required this.sheet,
    required this.onFillGap,
    required this.onCopyYesterday,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flags = sheet.aiFlags;
    final missing = sheet.hoursRemaining;

    return Card(
      color: AppColors.brandOrangeContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: const BorderSide(color: AppColors.brandOrange, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                  size: 16,
                  color: AppColors.brandOrange,
                ),
                const SizedBox(width: 6),
                Text(
                  'AI Insight',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.brandOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    PhosphorIcons.x(PhosphorIconsStyle.bold),
                    size: 16,
                    color: AppColors.brandOrange,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Summary ──────────────────────────────────────────────────
            Text(
              'You are ${missing.toStringAsFixed(1)} h short of your '
              '${sheet.weeklyTarget.toStringAsFixed(0)} h target this week.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.brandOrangeDark,
              ),
            ),

            const SizedBox(height: 8),

            // ── Flagged days ─────────────────────────────────────────────
            ...flags.map((e) => _FlagLine(entry: e, theme: theme)),

            const SizedBox(height: 10),

            // ── CTA buttons ──────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ...flags.map(
                  (e) => FilledButton(
                    onPressed: () => onFillGap(e),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandOrange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    child: Text('Fill ${_shortDay(e.date)}'),
                  ),
                ),
                OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandOrange,
                    side: const BorderSide(color: AppColors.brandOrange),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _shortDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

// ── Single flagged-day bullet ──────────────────────────────────────────────────
class _FlagLine extends StatelessWidget {
  final DayEntry entry;
  final ThemeData theme;

  const _FlagLine({required this.entry, required this.theme});

  @override
  Widget build(BuildContext context) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[entry.date.weekday - 1];

    final String description;
    if (entry.status == EntryStatus.workReportNoHours) {
      description = '$dayName — open work report with no hours logged';
    } else {
      description = '$dayName — no work report recorded';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.errorRed,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.brandOrangeDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

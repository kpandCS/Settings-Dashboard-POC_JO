import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../model/time_entry.dart';

/// Week selector row — ← Week of 19–25 May 2025 · 21.5 / 40h →
class WeekNavigator extends StatelessWidget {
  final WeeklyTimesheet sheet;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const WeekNavigator({
    super.key,
    required this.sheet,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            // ── Previous week ─────────────────────────────────────────────
            IconButton(
              onPressed: onPrevious,
              icon: Icon(
                PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
                size: 18,
                color: AppColors.brandOrange,
              ),
            ),

            // ── Week label + total ────────────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  Text(
                    _weekLabel(sheet.weekStart, sheet.weekEnd),
                    style: theme.textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: sheet.progressFraction,
                      minHeight: 5,
                      backgroundColor: AppColors.surfaceHover,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        sheet.progressFraction >= 1.0
                            ? AppColors.successGreen
                            : AppColors.brandOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Total: ${sheet.totalLogged}h / ${sheet.weeklyTarget.toStringAsFixed(0)}h',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: sheet.hoursRemaining > 0
                          ? AppColors.textSecondary
                          : AppColors.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Next week ─────────────────────────────────────────────────
            IconButton(
              onPressed: canGoForward ? onNext : null,
              icon: Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                size: 18,
                color: canGoForward
                    ? AppColors.brandOrange
                    : AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekLabel(DateTime start, DateTime end) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final sMonth = months[start.month - 1];
    final eMonth = months[end.month - 1];
    if (start.month == end.month) {
      return 'Week of ${start.day}–${end.day} $sMonth';
    }
    return 'Week of ${start.day} $sMonth – ${end.day} $eMonth';
  }
}

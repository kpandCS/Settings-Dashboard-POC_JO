import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../model/time_entry.dart';

/// One row in the daily breakdown list.
///
/// Layout (logged day):
///   Mon  ████████░░  8.0 h  Strand Bolig   [Signed]
///
/// Layout (AI-flagged day):
///   Thu  ──────────  0.0 h  No hours logged  ⚠ WR open
///   Fri  ──────────  0.0 h  No entry          ⚠ Missing
class DayEntryRow extends StatelessWidget {
  final DayEntry entry;

  const DayEntryRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeekend = entry.status == EntryStatus.weekend;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Day label ──────────────────────────────────────────────────
          SizedBox(
            width: 32,
            child: Text(
              _dayLabel(entry.date),
              style: theme.textTheme.labelMedium?.copyWith(
                color: isWeekend
                    ? AppColors.textSecondary
                    : entry.isGap
                        ? AppColors.errorRed
                        : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Progress bar ───────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: isWeekend
                ? const _WeekendBar()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: entry.progress,
                      minHeight: 7,
                      backgroundColor: AppColors.surfaceHover,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _barColor(entry),
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 10),

          // ── Hours ──────────────────────────────────────────────────────
          SizedBox(
            width: 42,
            child: Text(
              isWeekend ? '—' : '${entry.hoursLogged.toStringAsFixed(1)} h',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isWeekend
                    ? AppColors.textSecondary
                    : entry.isGap
                        ? AppColors.errorRed
                        : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          const SizedBox(width: 10),

          // ── Project / status info ──────────────────────────────────────
          Expanded(
            flex: 5,
            child: isWeekend
                ? const SizedBox.shrink()
                : _InfoSection(entry: entry, theme: theme),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // weekday: 1=Mon … 7=Sun
    return labels[date.weekday - 1];
  }

  Color _barColor(DayEntry e) {
    if (e.isGap) return AppColors.errorRed;
    if (e.progress >= 1.0) return AppColors.successGreen;
    return AppColors.brandOrange;
  }
}

// ── Weekend placeholder bar ────────────────────────────────────────────────────
class _WeekendBar extends StatelessWidget {
  const _WeekendBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: AppColors.outlineVariant,
      ),
    );
  }
}

// ── Right-side project name + WR badge ────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final DayEntry entry;
  final ThemeData theme;

  const _InfoSection({required this.entry, required this.theme});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color labelColor;

    if (entry.status == EntryStatus.workReportNoHours) {
      label = entry.projectName ?? 'Open WR – no hours';
      labelColor = AppColors.errorRed;
    } else if (entry.status == EntryStatus.gap) {
      label = 'No entry';
      labelColor = AppColors.errorRed;
    } else {
      label = entry.projectName ?? '';
      labelColor = AppColors.textSecondary;
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: labelColor),
          ),
        ),

        // WR status chip (only for logged entries with a WR)
        if (entry.workReportStatus != null &&
            entry.status == EntryStatus.logged) ...[
          const SizedBox(width: 5),
          _WrChip(status: entry.workReportStatus!),
        ],

        // AI warning icon for flagged entries
        if (entry.isGap) ...[
          const SizedBox(width: 4),
          Icon(
            PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
            size: 14,
            color: AppColors.errorRed,
          ),
        ],
      ],
    );
  }
}

// ── Work-report status chip ────────────────────────────────────────────────────
class _WrChip extends StatelessWidget {
  final String status; // "Signed" | "Pending"

  const _WrChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSigned = status == 'Signed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isSigned
            ? AppColors.successGreen.withValues(alpha: 0.12)
            : AppColors.brandOrangeContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isSigned ? AppColors.successGreen : AppColors.brandOrange,
        ),
      ),
    );
  }
}

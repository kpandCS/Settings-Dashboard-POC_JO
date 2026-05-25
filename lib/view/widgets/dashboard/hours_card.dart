import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/dashboard_data.dart';

class HoursCard extends StatelessWidget {
  final DashboardData data;

  const HoursCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = data.hoursRemaining;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.clock(PhosphorIconsStyle.fill),
                  size: 16,
                  color: AppColors.brandOrange,
                ),
                const SizedBox(width: 8),
                Text("Today's Hours", style: theme.textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_fmt(data.hoursToday)}h',
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/ ${_fmt(data.dailyTarget)}h',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: data.hoursProgress,
                minHeight: 8,
                backgroundColor: AppColors.brandOrangeContainer,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.brandOrange),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              remaining > 0
                  ? '${_fmt(remaining)}h remaining · Target ${_fmt(data.dailyTarget)}h'
                  : 'Daily target reached · ${_fmt(data.dailyTarget)}h',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/dashboard_data.dart';
import '../settings/settings_card.dart';

class ActiveProjectsCard extends StatelessWidget {
  final List<ActiveProjectSummary> projects;

  const ActiveProjectsCard({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsCard(
      children: [
        // ── Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.hardHat(PhosphorIconsStyle.fill),
                size: 16,
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 8),
              Text('Active Projects', style: theme.textTheme.labelMedium),
              const Spacer(),
              Text(
                'See all',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.brandOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Divider(),

        // ── Project rows ─────────────────────────────────────────────
        ...List.generate(projects.length, (i) {
          final p = projects[i];
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _StatusChip(status: p.status),
                              const SizedBox(width: 8),
                              Text(
                                '${_fmt(p.totalHours)}h · ${p.workReportCount} reports',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                      size: 16,
                      color: AppColors.textDisabled,
                    ),
                  ],
                ),
              ),
              if (i < projects.length - 1) const Divider(indent: 16),
            ],
          );
        }),
      ],
    );
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'Under Arbeid' => (AppColors.lightGreen, AppColors.successGreen),
      'Planlagt' => (AppColors.lightManualBlue, AppColors.manualBlue),
      _ => (AppColors.surfaceHover, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

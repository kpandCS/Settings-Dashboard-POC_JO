import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/dashboard_data.dart';
import '../settings/settings_card.dart';

class PendingReportsCard extends StatelessWidget {
  final List<PendingWorkReport> reports;

  const PendingReportsCard({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (reports.isEmpty) {
      return SettingsCard(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: AppColors.successGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('All reports signed', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ]);
    }

    return SettingsCard(
      children: [
        // ── Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill),
                size: 16,
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 8),
              Text('Pending Signatures', style: theme.textTheme.labelMedium),
              const SizedBox(width: 8),
              _CountBadge(count: reports.length),
            ],
          ),
        ),
        const Divider(),

        // ── Report rows ──────────────────────────────────────────────
        ...List.generate(reports.length, (i) {
          final r = reports[i];
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
                          Text(r.id, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            r.projectName,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_fmt(r.hoursLogged)}h · ${r.materialsCount} materials · ${r.date}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.textDisabled),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Sign'),
                    ),
                  ],
                ),
              ),
              if (i < reports.length - 1) const Divider(indent: 16),
            ],
          );
        }),
      ],
    );
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.brandOrangeContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.brandOrange,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/user_preferences.dart';
import 'settings_card.dart';
import 'source_chip.dart';

/// Populated Smart Defaults card — shows learned/manual rows with
/// source chips and an Edit button.
class SmartDefaultsSection extends StatelessWidget {
  final UserPreferences prefs;
  final VoidCallback onEdit;
  final VoidCallback onClear;

  const SmartDefaultsSection({
    super.key,
    required this.prefs,
    required this.onEdit,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rows = <_DefaultRow>[
      if (prefs.effectiveProjectName != null)
        _DefaultRow(
          label: 'Default project',
          value: prefs.effectiveProjectName!,
          isManual: prefs.projectIsManual,
        ),
      if (prefs.effectiveActivityName != null)
        _DefaultRow(
          label: 'Default activity',
          value: prefs.effectiveActivityName!,
          isManual: prefs.activityIsManual,
        ),
      if (prefs.effectiveWorkStartTime != null)
        _DefaultRow(
          label: 'Work day start',
          value: prefs.effectiveWorkStartTime!,
          isManual: prefs.startTimeIsManual,
        ),
    ];

    return SettingsCard(
      children: [
        // ── Header row ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                size: 16,
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 8),
              Text(
                'Smart Defaults',
                style: theme.textTheme.labelMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: Icon(
                  PhosphorIcons.pencilSimple(PhosphorIconsStyle.regular),
                  size: 15,
                ),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),

        // ── Default value rows ───────────────────────────────────────
        ...List.generate(rows.length, (i) {
          final row = rows[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.label,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            row.value,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SourceChip(isManual: row.isManual),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                const Divider(indent: 16),
            ],
          );
        }),

        // ── Reset footer ─────────────────────────────────────────────
        const Divider(),
        TextButton(
          onPressed: onClear,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Row(
            children: [
              Text('Reset to none'),
            ],
          ),
        ),
      ],
    );
  }
}

class _DefaultRow {
  final String label;
  final String value;
  final bool isManual;

  const _DefaultRow({
    required this.label,
    required this.value,
    required this.isManual,
  });
}

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Shown to first-time users while the app collects usage history.
/// Displays animated dot-progress and a manual setup fallback.
class EmptyDefaultsCard extends StatelessWidget {
  final int completedCount;
  final int totalRequired;
  final double progress; // 0.0 – 1.0
  final VoidCallback onSetManually;

  const EmptyDefaultsCard({
    super.key,
    required this.completedCount,
    required this.totalRequired,
    required this.progress,
    required this.onSetManually,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (totalRequired - completedCount).clamp(0, totalRequired);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon + Title row ─────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JobOffice is learning',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'your work patterns',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Animated 5-dot progress ──────────────────────────────
            Row(
              children: [
                Row(
                  children: List.generate(totalRequired, (i) {
                    final filled = i < completedCount;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        width: filled ? 26 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: filled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Text(
                  '$completedCount of $totalRequired reports',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Explanation ──────────────────────────────────────────
            Text(
              remaining > 0
                  ? 'Create $remaining more work '
                      '${remaining == 1 ? 'report' : 'reports'} and '
                      'JobOffice will suggest your smart defaults automatically.'
                  : 'Analysing your recent activity…',
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 4),

            // ── Manual setup link ────────────────────────────────────
            InkWell(
              onTap: onSetManually,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Set defaults manually instead',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../model/photo_entry.dart';

/// Bottom sheet that simulates the moment just after the camera shutter fires.
///
/// In production this is bypassed — the app goes straight to PhotoReviewScreen
/// after the camera captures an image. Here it lets the demo pick from 4
/// pre-baked scenarios so the full AI caption flow can be exercised.
class PhotoScenarioPicker extends StatelessWidget {
  const PhotoScenarioPicker({super.key});

  /// Shows the picker and returns the chosen [MockPhotoScenario], or null
  /// if the user dismisses.
  static Future<MockPhotoScenario?> show(BuildContext context) {
    return showModalBottomSheet<MockPhotoScenario>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PhotoScenarioPicker(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                PhosphorIcons.camera(PhosphorIconsStyle.fill),
                size: 18,
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 8),
              Text(
                'Velg scenario (POC-demo)',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'I produksjon åpnes dette direkte etter kamerabildet er tatt.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),

          // ── Scenario tiles ───────────────────────────────────────────────
          ...MockPhotoScenario.all.map(
            (s) => _ScenarioTile(
              scenario: s,
              onTap: () => Navigator.of(context).pop(s),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single scenario row in the picker
// ---------------------------------------------------------------------------
class _ScenarioTile extends StatelessWidget {
  final MockPhotoScenario scenario;
  final VoidCallback onTap;

  const _ScenarioTile({required this.scenario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outline),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Row(
            children: [
              // ── Mini photo thumbnail ─────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: Container(
                  width: 52,
                  height: 52,
                  color: scenario.thumbnailColor,
                  child: Icon(
                    scenario.icon,
                    color: Colors.white70,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── Info ─────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${scenario.projectName}  ·  ${scenario.trade.displayName}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      scenario.location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ── FDV badge preview ─────────────────────────────────────
              if (scenario.aiResult.likelyFdv)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'FDV',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),

              const SizedBox(width: 8),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                size: 14,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

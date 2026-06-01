import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_theme.dart';

/// Green badge shown when the AI determines the photo qualifies as
/// FDV (Forvaltning, Drift og Vedlikehold) documentation.
///
/// Mirrors the "Kan brukes som FDV-dokumentasjon" chip from the spec.
/// Worker can tap to learn more; upload category is pre-set to Documentation (4).
class FdvChip extends StatelessWidget {
  /// Short reason from Claude, e.g. "Rørinstallasjon" or "El-anlegg dokumentasjon".
  final String reason;

  /// Called when the info icon is tapped — show a tooltip / bottom sheet in production.
  final VoidCallback? onInfoTap;

  const FdvChip({
    super.key,
    required this.reason,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
            size: 15,
            color: AppColors.successGreen,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kan brukes som FDV-dokumentasjon',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successGreen,
                  ),
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    reason,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.successGreen.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onInfoTap != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onInfoTap,
              child: Icon(
                PhosphorIcons.info(PhosphorIconsStyle.regular),
                size: 15,
                color: AppColors.successGreen.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

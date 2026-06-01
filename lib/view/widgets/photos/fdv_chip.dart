import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_theme.dart';

/// Green badge shown when the AI determines the photo qualifies as
/// O&M (Operations & Maintenance / FDV) documentation.
///
/// Worker can tap the info icon to learn more; upload category is
/// pre-set to Documentation (4) automatically.
class FdvChip extends StatelessWidget {
  /// Short reason from Claude, e.g. "Pipe installation" or "Electrical system".
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
                  'Suitable for O&M documentation (FDV)',
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

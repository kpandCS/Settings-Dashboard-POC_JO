import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Small pill badge showing whether a default value came from
/// the AI learning engine ("Learned") or was set manually ("Manual").
///
/// BrandSync colours:
///   Learned → brand-orange tint  (#FFF0E6 bg / #A24907 text)
///   Manual  → neutral-blue tint  (#E8EDF5 bg / #3D5A87 text)
class SourceChip extends StatelessWidget {
  final bool isManual;

  const SourceChip({super.key, required this.isManual});

  @override
  Widget build(BuildContext context) {
    final color =
        isManual ? AppColors.manualBlue : AppColors.brandOrange;
    final bg =
        isManual ? AppColors.lightManualBlue : AppColors.brandOrangeContainer;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppRadius.small,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isManual ? 'Manual' : 'Learned',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

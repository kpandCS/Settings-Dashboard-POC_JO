import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/dashboard_data.dart';
import '../settings/settings_card.dart';

class RecentPhotosCard extends StatelessWidget {
  final List<RecentPhoto> photos;
  final int totalToday;

  const RecentPhotosCard({
    super.key,
    required this.photos,
    required this.totalToday,
  });

  // Grey-scale placeholders simulate photo thumbnails in this POC.
  static final _placeholderColors = [
    Colors.grey.shade300,
    Colors.grey.shade400,
    Colors.grey.shade500,
  ];

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
                PhosphorIcons.camera(PhosphorIconsStyle.fill),
                size: 16,
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 8),
              Text('Photos Today', style: theme.textTheme.labelMedium),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandOrangeContainer,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$totalToday',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.brandOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),

        // ── Thumbnail row ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: List.generate(photos.length, (i) {
              final photo = photos[i];
              final color =
                  _placeholderColors[i % _placeholderColors.length];
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: i < photos.length - 1 ? 8 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.medium),
                          child: Container(
                            color: color,
                            child: Icon(
                              PhosphorIcons.image(PhosphorIconsStyle.regular),
                              color: Colors.white54,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        photo.projectName,
                        style: theme.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        photo.timeAgo,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: AppColors.textDisabled),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

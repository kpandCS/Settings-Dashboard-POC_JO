import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../model/photo_entry.dart';

/// Orange insight card shown after AI analysis completes.
///
/// Displays the sparkle icon, "AI-forslag" header, the Norwegian caption,
/// and a "Kopiert til beskrivelse" confirmation note.
/// Also hosts the FDV chip and category toggle via [extra] slot.
class AiCaptionCard extends StatelessWidget {
  final AiCaptionResult result;

  /// Extra widgets rendered below the caption (FDV chip, category toggle).
  final List<Widget> extra;

  const AiCaptionCard({
    super.key,
    required this.result,
    this.extra = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.brandOrangeContainer,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.brandOrange.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                size: 14,
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 5),
              Text(
                'AI-forslag',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.brandOrange,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                'Kopiert til beskrivelse',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.brandOrange.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Caption text ─────────────────────────────────────────────
          Text(
            '"${result.caption}"',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.brandOrangeDark,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),

          // ── Extra widgets (FDV chip, category toggle) ─────────────────
          if (extra.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...extra,
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Analysing shimmer shown while the AI call is in flight
// ---------------------------------------------------------------------------
class AiAnalyzingCard extends StatefulWidget {
  const AiAnalyzingCard({super.key});

  @override
  State<AiAnalyzingCard> createState() => _AiAnalyzingCardState();
}

class _AiAnalyzingCardState extends State<AiAnalyzingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _fade =
      Tween<double>(begin: 0.5, end: 1.0).animate(_ctrl);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.brandOrangeContainer,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.brandOrange.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          FadeTransition(
            opacity: _fade,
            child: Icon(
              PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
              size: 16,
              color: AppColors.brandOrange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analyserer bilde…',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.brandOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'KI genererer norsk bildetekst og sjekker FDV-relevans',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.brandOrangeDark,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.brandOrange,
            ),
          ),
        ],
      ),
    );
  }
}

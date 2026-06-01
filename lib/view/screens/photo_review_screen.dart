import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../model/photo_entry.dart';
import '../../viewmodel/photo_review_viewmodel.dart';
import '../widgets/photos/ai_caption_card.dart';
import '../widgets/photos/fdv_chip.dart';

/// Photo Review screen — the step between "shutter fires" and "upload".
///
/// Production flow:
///   PhotoCameraReviewPage captures image → navigates here with Base64 bytes
///   → AI analysis runs in background → caption pre-fills description field
///   → worker accepts/edits → taps "Last opp" → POST /api/v1/projectFile
///
/// POC flow (identical UI, no real camera or API):
///   PhotoScenarioPicker → PhotoReviewScreen(scenario) → simulated analysis
class PhotoReviewScreen extends StatelessWidget {
  final MockPhotoScenario scenario;

  const PhotoReviewScreen({super.key, required this.scenario});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhotoReviewViewModel(scenario: scenario),
      child: const _PhotoReviewView(),
    );
  }
}

// ---------------------------------------------------------------------------
// Main view — reads ViewModel from context
// ---------------------------------------------------------------------------
class _PhotoReviewView extends StatefulWidget {
  const _PhotoReviewView();

  @override
  State<_PhotoReviewView> createState() => _PhotoReviewViewState();
}

class _PhotoReviewViewState extends State<_PhotoReviewView> {
  @override
  void initState() {
    super.initState();
    // Kick off AI analysis as soon as the screen is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoReviewViewModel>().startAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PhotoReviewViewModel>();
    final theme = Theme.of(context);
    final scenario = vm.scenario;

    // ── Upload success screen ────────────────────────────────────────────────
    if (vm.isUploaded) {
      return _UploadSuccessScreen(scenario: scenario);
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceContainer,
      appBar: AppBar(
        title: Text(
          'Gjennomse bilde',
          style: theme.textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Context chip: project + trade
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: Icon(
                PhosphorIcons.hardHat(PhosphorIconsStyle.fill),
                size: 14,
                color: AppColors.brandOrange,
              ),
              label: Text(
                scenario.projectName,
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: AppColors.brandOrangeContainer,
              labelStyle: const TextStyle(color: AppColors.brandOrangeDark),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Photo placeholder ──────────────────────────────────────
            _PhotoPlaceholder(scenario: scenario),

            const SizedBox(height: 16),

            // ── Photo metadata row ─────────────────────────────────────
            _MetadataRow(scenario: scenario, theme: theme),

            const SizedBox(height: 16),

            // ── AI analysis card (analyzing / ready / error) ───────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: vm.isAnalyzing
                  ? const AiAnalyzingCard(key: ValueKey('analyzing'))
                  : vm.aiResult != null
                      ? AiCaptionCard(
                          key: const ValueKey('ready'),
                          result: vm.aiResult!,
                          extra: [
                            // FDV chip (only when AI flags it)
                            if (vm.showFdvChip) ...[
                              FdvChip(
                                reason: vm.aiResult!.fdvReason,
                                onInfoTap: () => _showFdvInfo(context),
                              ),
                              const SizedBox(height: 8),
                            ],
                            // Category toggle
                            _CategoryToggle(
                              selected: vm.selectedCategory,
                              onChanged: vm.setCategory,
                            ),
                          ],
                        )
                      : vm.errorMessage != null
                          ? _ErrorCard(message: vm.errorMessage!, theme: theme)
                          : const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // ── Description field ─────────────────────────────────────
            Text(
              'Beskrivelse',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: vm.descriptionController,
              maxLines: 3,
              minLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Beskriv hva bildet viser…',
              ),
            ),

            const SizedBox(height: 8),

            // Category summary row (below text field)
            if (!vm.isAnalyzing && vm.aiResult != null)
              Row(
                children: [
                  Icon(
                    PhosphorIcons.tag(PhosphorIconsStyle.regular),
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Kategori: ${vm.selectedCategory.label}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

            const SizedBox(height: 28),

            // ── Upload button ──────────────────────────────────────────
            FilledButton.icon(
              onPressed: vm.isUploading || vm.isAnalyzing
                  ? null
                  : () => vm.upload(),
              icon: vm.isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(PhosphorIcons.cloudArrowUp(PhosphorIconsStyle.bold),
                      size: 18),
              label: Text(vm.isUploading ? 'Laster opp…' : 'Last opp'),
            ),

            const SizedBox(height: 12),

            // API hint (dev POC note)
            _ApiHint(theme: theme),
          ],
        ),
      ),
    );
  }

  void _showFdvInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: AppColors.successGreen, size: 20),
            const SizedBox(width: 8),
            const Text('Hva er FDV-dokumentasjon?'),
          ],
        ),
        content: const Text(
          'FDV = Forvaltning, Drift og Vedlikehold.\n\n'
          'Bilder av installert teknisk utstyr, rørarbeid, el-anlegg og '
          'konstruksjonsdetaljer skal arkiveres i FDV-permen per TEK17.\n\n'
          'KI har identifisert at dette bildet sannsynligvis er FDV-relevant '
          'og har forhåndsvalgt kategori Dokumentasjon (4). '
          'Du kan endre kategorien manuelt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Forstått'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo placeholder — simulates the captured image
// ---------------------------------------------------------------------------
class _PhotoPlaceholder extends StatelessWidget {
  final MockPhotoScenario scenario;

  const _PhotoPlaceholder({required this.scenario});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          color: scenario.thumbnailColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Simulated photo subject icon
              Icon(
                scenario.icon,
                size: 80,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              // Location label overlay
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                        size: 11,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        scenario.location,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // POC watermark
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'DEMO BILDE',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white60,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metadata row: trade, project, timestamp
// ---------------------------------------------------------------------------
class _MetadataRow extends StatelessWidget {
  final MockPhotoScenario scenario;
  final ThemeData theme;

  const _MetadataRow({required this.scenario, required this.theme});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeLabel =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        _MetaChip(
          icon: PhosphorIcons.wrench(PhosphorIconsStyle.fill),
          label: scenario.trade.displayName,
        ),
        const SizedBox(width: 8),
        _MetaChip(
          icon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
          label: timeLabel,
        ),
        const Spacer(),
        Text(
          'IMG_${now.millisecondsSinceEpoch % 100000}.jpg',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category toggle: Photo (2) ↔ Documentation (4)
// ---------------------------------------------------------------------------
class _CategoryToggle extends StatelessWidget {
  final ProjectFileCategory selected;
  final ValueChanged<ProjectFileCategory> onChanged;

  const _CategoryToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          PhosphorIcons.tag(PhosphorIconsStyle.fill),
          size: 13,
          color: AppColors.brandOrange,
        ),
        const SizedBox(width: 6),
        Text(
          'Kategori:',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.brandOrangeDark,
          ),
        ),
        const SizedBox(width: 8),
        ...ProjectFileCategory.values.map((cat) {
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brandOrange
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.brandOrange
                        : AppColors.brandOrange.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : AppColors.brandOrange,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error card shown when AI call fails
// ---------------------------------------------------------------------------
class _ErrorCard extends StatelessWidget {
  final String message;
  final ThemeData theme;

  const _ErrorCard({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
            color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
              size: 16, color: AppColors.errorRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upload success screen
// ---------------------------------------------------------------------------
class _UploadSuccessScreen extends StatelessWidget {
  final MockPhotoScenario scenario;

  const _UploadSuccessScreen({required this.scenario});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  size: 44,
                  color: AppColors.successGreen,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Bilde lastet opp!',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Lagret på ${scenario.projectName}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              // FDV confirmation if applicable
              if (scenario.aiResult.likelyFdv) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                        size: 13,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kategorisert som FDV-dokumentasjon',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  PhosphorIcons.house(PhosphorIconsStyle.fill),
                  size: 16,
                ),
                label: const Text('Tilbake til Min Dag'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Developer API hint strip
// ---------------------------------------------------------------------------
class _ApiHint extends StatelessWidget {
  final ThemeData theme;

  const _ApiHint({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIcons.code(PhosphorIconsStyle.bold),
              size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'AI: POST /v1/messages (Anthropic) — Base64 bilde + prosjektkontekst\n'
              'Upload: POST /api/v1/projectFile — uendret, kun description + fileCategory pre-fylt',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

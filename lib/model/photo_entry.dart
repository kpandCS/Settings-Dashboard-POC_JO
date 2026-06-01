import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ── Photo / FDV models — Intelligent Caption feature ─────────────────────────
//
// Production data path:
//   Worker captures image → Base64 bytes in memory (WorkReportFileDTO.FileData)
//   → POST /v1/messages (Anthropic) with image content block + trade context
//   → AiCaptionResult parsed from JSON response
//   → Worker accepts / edits → POST /api/v1/projectFile (unchanged API)
//
// This POC simulates the Anthropic call with pre-baked responses per scenario.

// ---------------------------------------------------------------------------
// ProjectFileCategory — mirrors the backend enum
// ---------------------------------------------------------------------------
enum ProjectFileCategory {
  /// Category 2 — standard site photo.
  photo,

  /// Category 4 — FDV (Forvaltning, Drift og Vedlikehold) documentation.
  /// Pre-selected by AI when likelyFdv == true.
  documentation,
}

extension ProjectFileCategoryX on ProjectFileCategory {
  /// Norwegian display label shown in the category toggle.
  String get label =>
      this == ProjectFileCategory.photo ? 'Photo (2)' : 'Documentation (4)';

  /// Backend integer value sent to POST /api/v1/projectFile.
  int get backendValue =>
      this == ProjectFileCategory.photo ? 2 : 4;
}

// ---------------------------------------------------------------------------
// TradeType — employee's trade / profession
// ---------------------------------------------------------------------------
enum TradeType { vvs, elektriker, general }

extension TradeTypeX on TradeType {
  String get displayName {
    switch (this) {
      case TradeType.vvs:
        return 'Plumber';
      case TradeType.elektriker:
        return 'Electrician';
      case TradeType.general:
        return 'Tradesperson';
    }
  }
}

// ---------------------------------------------------------------------------
// AiCaptionResult — what Claude would return
// ---------------------------------------------------------------------------
class AiCaptionResult {
  /// One-sentence English description of the photo.
  final String caption;

  /// True when the photo likely qualifies as FDV documentation.
  final bool likelyFdv;

  /// Short reason shown inside the O&M chip, e.g. "Pipe installation".
  final String fdvReason;

  /// Suggested upload category driven by likelyFdv.
  ProjectFileCategory get suggestedCategory => likelyFdv
      ? ProjectFileCategory.documentation
      : ProjectFileCategory.photo;

  const AiCaptionResult({
    required this.caption,
    required this.likelyFdv,
    required this.fdvReason,
  });
}

// ---------------------------------------------------------------------------
// MockPhotoScenario — simulated "photo just taken" scenario
// ---------------------------------------------------------------------------
class MockPhotoScenario {
  final String id;
  final String title;          // short title shown in picker
  final String projectName;
  final TradeType trade;
  final Color thumbnailColor;  // placeholder background colour
  final IconData icon;         // placeholder icon (resolved with style in widget)
  final String location;       // e.g. "Kjøkken, 2. etg"
  final AiCaptionResult aiResult;

  const MockPhotoScenario({
    required this.id,
    required this.title,
    required this.projectName,
    required this.trade,
    required this.thumbnailColor,
    required this.icon,
    required this.location,
    required this.aiResult,
  });

  // ── Four representative scenarios ────────────────────────────────────────
  // Non-const statics — PhosphorIcons calls are not const-constructible.

  static final pipe = MockPhotoScenario(
    id: 'sc-1',
    title: 'Kitchen Pipe Installation',
    projectName: 'Strand Bolig',
    trade: TradeType.vvs,
    thumbnailColor: const Color(0xFF1565C0),
    icon: PhosphorIcons.pipe(PhosphorIconsStyle.regular),
    location: 'Kitchen, 2nd floor',
    aiResult: const AiCaptionResult(
      caption:
          'Completed pipe installation in kitchen wall — ready for sealing and tiling.',
      likelyFdv: true,
      fdvReason: 'Pipe installation',
    ),
  );

  static final electrical = MockPhotoScenario(
    id: 'sc-2',
    title: 'Electrical Panel',
    projectName: 'Bergkvist Bolig',
    trade: TradeType.elektriker,
    thumbnailColor: const Color(0xFFE65100),
    icon: PhosphorIcons.lightning(PhosphorIconsStyle.regular),
    location: 'Technical room, 1st floor',
    aiResult: const AiCaptionResult(
      caption:
          'New electrical distribution board installed in technical room — all circuits labelled and connected.',
      likelyFdv: true,
      fdvReason: 'Electrical system',
    ),
  );

  static final overview = MockPhotoScenario(
    id: 'sc-3',
    title: 'Site Overview',
    projectName: 'Lofoten Hytte',
    trade: TradeType.general,
    thumbnailColor: const Color(0xFF37474F),
    icon: PhosphorIcons.buildings(PhosphorIconsStyle.regular),
    location: 'Outdoor, north side',
    aiResult: const AiCaptionResult(
      caption:
          'Site overview week 21 — groundworks in progress, formwork elements in position.',
      likelyFdv: false,
      fdvReason: '',
    ),
  );

  static final delivery = MockPhotoScenario(
    id: 'sc-4',
    title: 'Material Delivery',
    projectName: 'Bergkvist Bolig',
    trade: TradeType.general,
    thumbnailColor: const Color(0xFF4E342E),
    icon: PhosphorIcons.package(PhosphorIconsStyle.regular),
    location: 'Entrance area',
    aiResult: const AiCaptionResult(
      caption:
          'Delivery of 45 insulation boards (50 mm) — verified against delivery note and approved.',
      likelyFdv: false,
      fdvReason: '',
    ),
  );

  static List<MockPhotoScenario> get all => [pipe, electrical, overview, delivery];
}

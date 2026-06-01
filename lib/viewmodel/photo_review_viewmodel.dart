import 'package:flutter/material.dart';
import '../model/photo_entry.dart';
import '../service/ai_caption_service.dart';

// ---------------------------------------------------------------------------
// State machine
// ---------------------------------------------------------------------------
enum PhotoReviewState {
  /// Screen just opened — analysis not yet started.
  idle,

  /// AI analysis request in flight (spinner shown).
  analyzing,

  /// AI result received — caption + FDV result visible.
  ready,

  /// User tapped "Last opp" — upload in progress.
  uploading,

  /// Upload complete — success state shown.
  uploaded,
}

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------
class PhotoReviewViewModel extends ChangeNotifier {
  final MockPhotoScenario scenario;
  final AiCaptionService _service;

  PhotoReviewViewModel({
    required this.scenario,
    AiCaptionService? service,
  }) : _service = service ?? const AiCaptionService();

  // ── State ─────────────────────────────────────────────────────────────────
  PhotoReviewState _state = PhotoReviewState.idle;
  AiCaptionResult? _aiResult;
  String? _errorMessage;

  /// Description field bound to the editable TextField.
  late final TextEditingController descriptionController =
      TextEditingController();

  /// Selected upload category — may differ from AI suggestion if worker overrides.
  ProjectFileCategory _selectedCategory = ProjectFileCategory.photo;

  /// True once the worker has manually changed the category chip.
  bool _categoryOverridden = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  PhotoReviewState get state => _state;
  AiCaptionResult? get aiResult => _aiResult;
  String? get errorMessage => _errorMessage;
  ProjectFileCategory get selectedCategory => _selectedCategory;
  bool get isAnalyzing => _state == PhotoReviewState.analyzing;
  bool get isUploading => _state == PhotoReviewState.uploading;
  bool get isUploaded => _state == PhotoReviewState.uploaded;
  bool get showFdvChip =>
      _aiResult != null && _aiResult!.likelyFdv;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Called automatically when the PhotoReviewScreen is first displayed.
  Future<void> startAnalysis() async {
    if (_state != PhotoReviewState.idle) return;
    _state = PhotoReviewState.analyzing;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.analyzePhoto(scenario: scenario);
      _aiResult = result;
      descriptionController.text = result.caption;

      // Auto-select category unless the worker already overrode it.
      if (!_categoryOverridden) {
        _selectedCategory = result.suggestedCategory;
      }

      _state = PhotoReviewState.ready;
    } catch (e) {
      _errorMessage = 'KI-analyse mislyktes. Skriv inn beskrivelse manuelt.';
      _state = PhotoReviewState.ready; // still let them upload manually
    }

    notifyListeners();
  }

  /// Worker manually toggles the upload category.
  void setCategory(ProjectFileCategory category) {
    _categoryOverridden = true;
    _selectedCategory = category;
    notifyListeners();
  }

  /// Worker taps "Last opp" — simulates POST /api/v1/projectFile.
  ///
  /// Production payload:
  /// {
  ///   "projectId": ...,
  ///   "description": descriptionController.text,
  ///   "fileCategory": selectedCategory.backendValue,  // 2 or 4
  ///   "fileData": "<base64>",                         // already in memory
  ///   "fileName": "IMG_20250519_143022.jpg",
  ///   "contentType": "image/jpeg",
  /// }
  Future<void> upload() async {
    if (_state == PhotoReviewState.uploading ||
        _state == PhotoReviewState.uploaded) return;

    _state = PhotoReviewState.uploading;
    notifyListeners();

    // Simulate upload round-trip.
    await Future.delayed(const Duration(milliseconds: 900));

    _state = PhotoReviewState.uploaded;
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}

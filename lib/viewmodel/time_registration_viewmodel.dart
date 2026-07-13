import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../model/activity.dart';
import '../model/project.dart';
import '../model/time_entry.dart';
import '../service/voice_command_parser.dart';
import '../service/voice_time_channel.dart';
import 'dashboard_viewmodel.dart';

enum VoiceRegistrationStatus { idle, listening, reviewing, unavailable }

/// Drives voice-based time registration: the in-app mic button, plus
/// consuming entries that Siri logged via App Intents while the app wasn't
/// running. Both paths funnel into [DashboardViewModel.applyTimeEntry].
class TimeRegistrationViewModel extends ChangeNotifier {
  TimeRegistrationViewModel(this._dashboardViewModel);

  final DashboardViewModel _dashboardViewModel;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;

  VoiceRegistrationStatus status = VoiceRegistrationStatus.idle;
  String transcript = '';
  VoiceParseResult? parseResult;
  String? errorMessage;
  List<TimeEntry> lastAppliedSiriEntries = const [];

  Future<void> startListening() async {
    errorMessage = null;

    if (!_speechInitialized) {
      _speechInitialized = await _speech.initialize(
        onError: (error) {
          errorMessage = error.errorMsg;
          status = VoiceRegistrationStatus.idle;
          notifyListeners();
        },
        onStatus: (speechStatus) {
          if ((speechStatus == 'done' || speechStatus == 'notListening') &&
              status == VoiceRegistrationStatus.listening) {
            status = transcript.isEmpty
                ? VoiceRegistrationStatus.idle
                : VoiceRegistrationStatus.reviewing;
            notifyListeners();
          }
        },
      );
    }

    if (!_speechInitialized) {
      status = VoiceRegistrationStatus.unavailable;
      errorMessage = 'Speech recognition is not available on this device.';
      notifyListeners();
      return;
    }

    transcript = '';
    parseResult = null;
    status = VoiceRegistrationStatus.listening;
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        transcript = result.recognizedWords;
        parseResult = VoiceCommandParser.parse(transcript);
        notifyListeners();
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    status = transcript.isEmpty ? VoiceRegistrationStatus.idle : VoiceRegistrationStatus.reviewing;
    notifyListeners();
  }

  void updateManualText(String text) {
    transcript = text;
    parseResult = VoiceCommandParser.parse(text);
    status = VoiceRegistrationStatus.reviewing;
    notifyListeners();
  }

  void overrideProject(Project project) {
    parseResult = (parseResult ?? const VoiceParseResult(rawText: '')).copyWith(project: project);
    notifyListeners();
  }

  void overrideActivity(Activity activity) {
    parseResult = (parseResult ?? const VoiceParseResult(rawText: '')).copyWith(activity: activity);
    notifyListeners();
  }

  void overrideHours(double hours) {
    parseResult = (parseResult ?? const VoiceParseResult(rawText: '')).copyWith(hours: hours);
    notifyListeners();
  }

  /// Applies the currently reviewed [parseResult], if complete. Returns
  /// whether an entry was logged.
  bool confirm() {
    final result = parseResult;
    if (result == null || !result.isComplete) return false;
    _dashboardViewModel.applyTimeEntry(
      TimeEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        projectName: result.project!.name,
        activityName: result.activity!.name,
        hours: result.hours!,
        loggedAt: DateTime.now(),
        source: TimeEntrySource.voiceInApp,
      ),
    );
    reset();
    return true;
  }

  void reset() {
    transcript = '';
    parseResult = null;
    status = VoiceRegistrationStatus.idle;
    errorMessage = null;
    notifyListeners();
  }

  /// Pulls any time entries Siri logged while the app was backgrounded and
  /// folds them into the dashboard. Safe to call frequently (no-op on
  /// Android, and empty when there's nothing pending).
  Future<List<TimeEntry>> consumePendingSiriEntries() async {
    final rawEntries = await VoiceTimeChannel.consumePendingEntries();
    if (rawEntries.isEmpty) return const [];

    final applied = <TimeEntry>[];
    for (final raw in rawEntries) {
      final hours = (raw['hours'] as num?)?.toDouble() ?? 0;
      if (hours <= 0) continue;
      final entry = TimeEntry(
        id: raw['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
        projectName: raw['projectName'] as String? ?? 'Unknown project',
        activityName: raw['activityName'] as String? ?? 'Unknown activity',
        hours: hours,
        loggedAt: DateTime.tryParse(raw['loggedAt'] as String? ?? '') ?? DateTime.now(),
        source: TimeEntrySource.siri,
      );
      _dashboardViewModel.applyTimeEntry(entry);
      applied.add(entry);
    }
    lastAppliedSiriEntries = applied;
    notifyListeners();
    return applied;
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}

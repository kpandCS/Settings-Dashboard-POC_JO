import 'dart:io';

import 'package:flutter/services.dart';

/// Bridges to the native iOS side, which stores time entries logged via
/// Siri / App Intents (see ios/Runner/AppIntents) in an App Group and hands
/// them over here the next time the app is foregrounded.
class VoiceTimeChannel {
  VoiceTimeChannel._();

  static const MethodChannel _channel =
      MethodChannel('com.eg.settingsScreenPoc/voice_time_entries');

  static Future<List<Map<String, dynamic>>> consumePendingEntries() async {
    if (!Platform.isIOS) return [];
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('consumePendingEntries');
      if (result == null) return [];
      return result
          .whereType<Map>()
          .map((m) => m.map((key, value) => MapEntry(key.toString(), value)))
          .toList();
    } on MissingPluginException {
      return [];
    } on PlatformException {
      return [];
    }
  }
}

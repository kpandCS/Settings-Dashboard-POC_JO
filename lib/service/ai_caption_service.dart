import '../model/photo_entry.dart';

// ── AI Caption Service — simulated Anthropic Vision call ─────────────────────
//
// PRODUCTION IMPLEMENTATION:
// ─────────────────────────────────────────────────────────────────────────────
// final response = await http.post(
//   Uri.parse('https://api.anthropic.com/v1/messages'),
//   headers: {
//     'x-api-key': apiKey,
//     'anthropic-version': '2023-06-01',
//     'content-type': 'application/json',
//   },
//   body: jsonEncode({
//     'model': 'claude-opus-4-5',
//     'max_tokens': 256,
//     'messages': [
//       {
//         'role': 'user',
//         'content': [
//           {
//             'type': 'image',
//             'source': {
//               'type': 'base64',
//               'media_type': 'image/jpeg',
//               'data': base64ImageData,   // already in memory as WorkReportFileDTO.FileData
//             },
//           },
//           {
//             'type': 'text',
//             'text': _buildPrompt(projectName, trade, materials),
//           },
//         ],
//       },
//     ],
//   }),
// );
// final json = jsonDecode(response.body);
// final text = json['content'][0]['text'] as String;
// final result = jsonDecode(text) as Map<String, dynamic>;
// return AiCaptionResult(
//   caption: result['caption'] as String,
//   likelyFdv: result['likelyFdv'] as bool,
//   fdvReason: result['fdvReason'] as String? ?? '',
// );
//
// PROMPT TEMPLATE:
// "You are a ${trade.displayName} on project '$projectName'.
//  Look at this image and respond ONLY with valid JSON:
//  { \"caption\": \"<1 sentence English description>\",
//    \"likelyFdv\": <true|false>,
//    \"fdvReason\": \"<short English reason, empty string if false>\" }
//  likelyFdv = true if the photo shows installed technical equipment,
//  pipework, electrical systems or construction details required in the
//  O&M (Operations & Maintenance) documentation file per TEK17."
//
// COST NOTE:
// Vision calls cost ~1 000–2 000 tokens per image at current Anthropic pricing.
// Negligible for a VVS company logging ~20 photos/day across 5 workers.
// Feature can be toggled per-worker in Settings to control volume.
// ─────────────────────────────────────────────────────────────────────────────

class AiCaptionService {
  const AiCaptionService();

  /// Simulates the Anthropic /v1/messages vision call.
  ///
  /// In production, [base64Image] (already held in memory as FileData) and
  /// [scenario] metadata are posted to the Anthropic API.
  /// Here we simply wait to mimic network latency and return pre-baked data.
  Future<AiCaptionResult> analyzePhoto({
    required MockPhotoScenario scenario,
    // ignore: unused_element
    String? base64Image, // placeholder — populated from camera in production
  }) async {
    // Simulate Anthropic API round-trip: 1.2–2.0 s depending on image size.
    await Future.delayed(const Duration(milliseconds: 1600));
    return scenario.aiResult;
  }
}

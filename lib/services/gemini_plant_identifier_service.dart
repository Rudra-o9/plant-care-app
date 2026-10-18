import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/api_config.dart';
import '../models/plant_identification_model.dart';

/// Plant identification using Google Gemini Vision API.
/// Free tier: 15 requests/minute, 1500/day — plenty for a presentation.
/// Get your key at https://aistudio.google.com/apikey
class GeminiPlantIdentifierService {
  static bool get isAvailable => ApiConfig.geminiApiKey.trim().isNotEmpty;

  static Future<PlantIdentificationModel?> identify(
    Uint8List imageBytes,
    String imagePath,
    String mimeType,
  ) async {
    if (!isAvailable) {
      debugPrint('[Gemini] No API key configured. Skipping Gemini.');
      return null;
    }

    try {
      debugPrint('[Gemini] Starting plant identification...');
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: ApiConfig.geminiApiKey,
      );

      const prompt = '''
You are a professional botanist. Analyze this plant image and identify it.
Return ONLY a valid JSON object (no markdown, no explanation) in this exact format:
{
  "found": true,
  "common_name": "Coconut Palm",
  "scientific_name": "Cocos nucifera",
  "scientific_name_simple": "Cocos nucifera",
  "genus": "Cocos",
  "family": "Arecaceae",
  "confidence": 0.95,
  "other_names": ["Coconut Tree", "Nariyal"],
  "alt_common_name": "Date Palm",
  "alt_scientific_name": "Phoenix dactylifera",
  "alt_scientific_name_simple": "Phoenix dactylifera",
  "alt_genus": "Phoenix",
  "alt_family": "Arecaceae",
  "alt_confidence": 0.72,
  "alt_other_names": ["Date Tree"]
}
If you cannot identify any plant, return: {"found": false}
''';

      final response = await model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, imageBytes),
        ]),
      ]);

      final text = response.text ?? '';
      debugPrint('[Gemini] Raw response: ${text.substring(0, text.length.clamp(0, 300))}');

      // Extract JSON from response (handle markdown code blocks if present)
      final jsonStr = _extractJson(text);
      if (jsonStr == null) {
        debugPrint('[Gemini] Could not extract JSON from response');
        return null;
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (json['found'] != true) {
        debugPrint('[Gemini] Plant not found in image');
        return null;
      }

      final best = PlantIdentificationResult(
        score: (json['confidence'] as num?)?.toDouble() ?? 0.9,
        scientificName: json['scientific_name']?.toString() ?? '',
        scientificNameWithoutAuthor: json['scientific_name_simple']?.toString() ?? '',
        genus: json['genus']?.toString() ?? '',
        family: json['family']?.toString() ?? '',
      commonNames: <String>[
        json['common_name']?.toString() ?? '',
        ...((json['other_names'] as List?)?.map((e) => e.toString()) ?? <String>[]),
      ].where((s) => s.isNotEmpty).toList(),
        imageUrl: null,
      );

      final altCommon = json['alt_common_name']?.toString() ?? '';
      final hasAlt = altCommon.isNotEmpty;

      final alt = hasAlt
          ? PlantIdentificationResult(
              score: (json['alt_confidence'] as num?)?.toDouble() ?? 0.6,
              scientificName: json['alt_scientific_name']?.toString() ?? '',
              scientificNameWithoutAuthor: json['alt_scientific_name_simple']?.toString() ?? '',
              genus: json['alt_genus']?.toString() ?? '',
              family: json['alt_family']?.toString() ?? '',
              commonNames: <String>[
                altCommon,
                ...((json['alt_other_names'] as List?)?.map((e) => e.toString()) ?? <String>[]),
              ].where((s) => s.isNotEmpty).toList(),
              imageUrl: null,
            )
          : null;

      debugPrint('[Gemini] Identified: ${best.commonName} (${(best.score * 100).round()}%)');

      return PlantIdentificationModel(
        inputImagePath: imagePath,
        bestMatch: best,
        results: [best, ?alt],
        predictedOrgans: const ['leaf', 'habit'],
        apiVersion: 'Gemini 1.5 Flash',
        quotaRemaining: null,
        isAiFallback: false, // Gemini IS a real AI — not a keyword guess
      );
    } catch (e, stack) {
      debugPrint('[Gemini] Error: $e\n$stack');
      return null;
    }
  }

  static String? _extractJson(String text) {
    // Try direct parse
    try {
      jsonDecode(text);
      return text.trim();
    } catch (_) {}

    // Strip markdown code blocks
    final codeBlock = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = codeBlock.firstMatch(text);
    if (match != null) {
      final inner = match.group(1)?.trim();
      try {
        if (inner != null) jsonDecode(inner);
        return inner;
      } catch (_) {}
    }

    // Find first { ... } block
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      final candidate = text.substring(start, end + 1);
      try {
        jsonDecode(candidate);
        return candidate;
      } catch (_) {}
    }

    return null;
  }
}

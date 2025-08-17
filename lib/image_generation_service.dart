import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:misomia/emotion_service.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class ImageGenerationService {
  // No API key needed here, as it's handled by the Cloud Function.

  Future<Uint8List?> generateAnimeImage(Emotion emotion, String? customPrompt, String? negativePrompt) async {
    // The API call is commented out by default.
//    return null; // Returning null to prevent errors until enabled.

    final prompt = customPrompt != null && customPrompt.isNotEmpty
        ? "$customPrompt, feeling ${emotion.name}"
        : """anime girl, bust-up, short dark hair, pastel colored T-shirt,
          clean line art, flat colors, cel-shading, expressive eyes, simple lighting,
          Japanese anime style, feeling ${emotion.name}""";

    final negativePromptString = negativePrompt != null && negativePrompt.isNotEmpty
        ? negativePrompt
        : "realistic, photo, 3D render, painterly, dramatic lighting, shadows, sketch";

    final url = Uri.parse('https://us-central1-misomia.cloudfunctions.net/getHuggingFaceImage');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'negative_prompt': negativePromptString,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String base64Image = data['image'];
        return base64Decode(base64Image);
      } else {
        debugPrint('Cloud Function Error (Image): ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception during Cloud Function call (Image): $e');
      return null;
    }
  }
}
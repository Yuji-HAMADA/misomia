import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint

enum Emotion {
  neutral,
  happy,
  sad,
  angry,
  surprised,
}

class EmotionService {
  // No API key needed here, as it's handled by the Cloud Function.

  Future<Emotion> getEmotion(String text) async {
    // Mock implementation is active by default.
//    return await _getMockEmotion(text); // Removed _getMockEmotion method

    final url = Uri.parse('https://us-central1-misomia.cloudfunctions.net/getGeminiEmotion');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String label = data['emotion'].toString().trim().toLowerCase();
        return _mapLabelToEmotion(label);
      } else {
        debugPrint('Cloud Function Error (Emotion): ${response.statusCode} ${response.body}'); // Changed from print to debugPrint
        return Emotion.neutral;
      }
    } catch (e) {
      debugPrint('Exception during Cloud Function call (Emotion): $e'); // Changed from print to debugPrint
      return Emotion.neutral;
    }
  }

  Emotion _mapLabelToEmotion(String label) {
    switch (label) {
      case 'happy':
        return Emotion.happy;
      case 'sad':
        return Emotion.sad;
      case 'angry':
        return Emotion.angry;
      case 'surprised':
        return Emotion.surprised;
      case 'neutral':
      default:
        return Emotion.neutral;
    }
  }
}
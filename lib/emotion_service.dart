import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

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
//    return await _getMockEmotion(text);

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
        print('Cloud Function Error (Emotion): ${response.statusCode} ${response.body}');
        return Emotion.neutral;
      }
    } catch (e) {
      print('Exception during Cloud Function call (Emotion): $e');
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

  Future<Emotion> _getMockEmotion(String text) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final emotions = Emotion.values;
    return emotions[text.length % emotions.length];
  }
}

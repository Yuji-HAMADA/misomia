import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:misomia/emotion_service.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class ReplyService {
  // No API key needed here, as it's handled by the Cloud Function.

  Future<String> getReply(Emotion emotion, String userMessage) async {

    final url = Uri.parse('https://us-central1-misomia.cloudfunctions.net/getGeminiReply');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emotion': emotion.name, 'userMessage': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'].toString().trim();
      } else {
        debugPrint('Cloud Function Error (Reply): ${response.statusCode} ${response.body}');
        return _getRuleBasedReply(emotion);
      }
    } catch (e) {
      debugPrint('Exception during Cloud Function call (Reply): $e');
        return _getRuleBasedReply(emotion);
    }
  }

  String _getRuleBasedReply(Emotion emotion) {
    final possibleReplies = _replies[emotion] ?? _replies[Emotion.neutral]!;
    return possibleReplies[Random().nextInt(possibleReplies.length)];
  }

  static final Map<Emotion, List<String>> _replies = {
    Emotion.happy: ["That's great to hear!", "So happy for you!"],
    Emotion.sad: ["I'm sorry to hear that.", "That sounds tough."],
    Emotion.angry: ["I understand your frustration.", "That does sound upsetting."],
    Emotion.surprised: ["Wow, really?", "That's surprising!"],
    Emotion.neutral: ["I see.", "Got it."],
  };
}
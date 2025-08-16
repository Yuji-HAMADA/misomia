import 'package:misomia/emotion_service.dart';

class AvatarService {
  String generateAvatarSvg(Emotion emotion) {
    String eyePath, mouthPath;

    switch (emotion) {
      case Emotion.happy:
        eyePath = 'M 8,12 C 10,14 14,14 16,12'; // Upward curve
        mouthPath = 'M 10,20 C 12,24 18,24 20,20'; // Wide smile
        break;
      case Emotion.sad:
        eyePath = 'M 8,14 C 10,12 14,12 16,14'; // Downward curve
        mouthPath = 'M 10,22 C 12,18 18,18 20,22'; // Frown
        break;
      case Emotion.angry:
        eyePath = 'M 8,14 L 12,12 L 16,14'; // Angled down
        mouthPath = 'M 10,22 C 12,20 18,20 20,22'; // Straight line / slight frown
        break;
      case Emotion.surprised:
        eyePath = 'M 12,12 m -2,0 a 2,2 0 1,0 4,0 a 2,2 0 1,0 -4,0'; // Circle
        mouthPath = 'M 15,22 m -2,0 a 2,2 0 1,0 4,0 a 2,2 0 1,0 -4,0'; // Open circle mouth
        break;
      case Emotion.neutral:
      default:
        eyePath = 'M 8,13 H 16'; // Straight line
        mouthPath = 'M 10,22 H 20'; // Straight line
        break;
    }

    // A simple SVG template for a face.
    return '''
    <svg viewBox="0 0 30 30" xmlns="http://www.w3.org/2000/svg">
      <!-- Head -->
      <circle cx="15" cy="15" r="14" fill="#E0E0E0" stroke="#9E9E9E" stroke-width="1"/>

      <!-- Left Eye -->
      <path d="$eyePath" transform="translate(-3, 0)" stroke="#212121" stroke-width="0.8" fill="none" stroke-linecap="round"/>

      <!-- Right Eye -->
      <path d="$eyePath" transform="translate(7, 0)" stroke="#212121" stroke-width="0.8" fill="none" stroke-linecap="round"/>

      <!-- Mouth -->
      <path d="$mouthPath" stroke="#212121" stroke-width="0.8" fill="none" stroke-linecap="round"/>
    </svg>
    ''';
  }
}

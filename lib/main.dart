import 'package:flutter/material.dart';
import 'package:misomia/emotion_service.dart';
import 'package:misomia/reply_service.dart';
import 'package:misomia/image_generation_service.dart'; // New import
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MisomiaApp());
}

// Updated data class to hold the user's text and the bot's reply.
class ChatMessage {
  final String userText;
  final String botReply;
  final Emotion emotion;

  ChatMessage({
    required this.userText,
    required this.botReply,
    required this.emotion,
  });
}

class MisomiaApp extends StatelessWidget {
  const MisomiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misomia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final EmotionService _emotionService = EmotionService();
  final ReplyService _replyService = ReplyService();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imagePromptController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
    _imagePromptController.addListener(() {
      _savePrompt(_imagePromptController.text);
    });
  }

  @override
  void dispose() {
    _imagePromptController.removeListener(() {
      _savePrompt(_imagePromptController.text);
    });
    _imagePromptController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPrompt = prefs.getString('imagePrompt');
    if (savedPrompt != null) {
      setState(() {
        _imagePromptController.text = savedPrompt;
      });
    }
  }

  Future<void> _savePrompt(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('imagePrompt', prompt);
  }

  void _analyzeTextMessage() async {
    final text = _textController.text;
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final emotion = await _emotionService.getEmotion(text);
      final reply = await _replyService.getReply(emotion, text);

      setState(() {
        _messages.add(ChatMessage(
          userText: text,
          botReply: reply,
          emotion: emotion,
        ));
      });
    } catch (e) {
      debugPrint('Error processing message: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastEmotion = _messages.isEmpty ? Emotion.neutral : _messages.last.emotion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Misomia'),
      ),
      drawer: ImagePromptDrawer(controller: _imagePromptController),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Flexible(
              child: AvatarView(emotion: lastEmotion, imagePrompt: _imagePromptController.text.isEmpty ? null : _imagePromptController.text),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Card(
                    child: ListTile(
                      title: Text('You: ${message.userText}'),
                      subtitle: Text('Avatar: ${message.botReply}'),
                      trailing: Text(message.emotion.toString().split('.').last),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _analyzeTextMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                _isLoading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _analyzeTextMessage,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePromptDrawer extends StatelessWidget {
  final TextEditingController controller;

  const ImagePromptDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Image Prompt',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter image prompt (e.g., "anime girl with blue hair")',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarView extends StatefulWidget {
  final Emotion emotion;
  final String? imagePrompt; // New parameter

  const AvatarView({super.key, required this.emotion, this.imagePrompt});

  @override
  State<AvatarView> createState() => _AvatarViewState();
}

class _AvatarViewState extends State<AvatarView> {
  final ImageGenerationService _imageGenerationService = ImageGenerationService();
  Uint8List? _imageData;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _generateImage(widget.emotion, widget.imagePrompt);
  }

  @override
  void didUpdateWidget(covariant AvatarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emotion != oldWidget.emotion || widget.imagePrompt != oldWidget.imagePrompt) {
      _generateImage(widget.emotion, widget.imagePrompt);
    }
  }

  void _generateImage(Emotion emotion, String? imagePrompt) async {
    setState(() {
      _isLoadingImage = true;
      _imageData = null; // Clear previous image
    
    });

    final imageData = await _imageGenerationService.generateAnimeImage(emotion, imagePrompt);

    setState(() {
      _imageData = imageData;
      _isLoadingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight - keyboardHeight; // Approximate available height
    final imageWidth = screenWidth > 600 ? 600.0 : screenWidth; // Max width of 600 for larger screens
    final imageHeight = availableHeight * 0.4; // Take 40% of available height, adjust as needed

    if (_isLoadingImage) {
      return SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (_imageData != null) {
      return Image.memory(
        _imageData!,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.contain,
      );
    } else {
      // Fallback if image generation fails
      return SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: const Center(child: Icon(Icons.broken_image, size: 50)),
      );
    }
  }
}
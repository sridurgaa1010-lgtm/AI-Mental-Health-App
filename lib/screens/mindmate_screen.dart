
import 'package:flutter/material.dart';
import '../services/ai_chat_service.dart';

class MindMateScreen extends StatefulWidget {
  const MindMateScreen({super.key});

  @override
  State<MindMateScreen> createState() => _MindMateScreenState();
}

class _MindMateScreenState extends State<MindMateScreen> {
  final AiChatService aiService = AiChatService();

  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [];

  bool isLoading = false;

  static const Color plum = Color(0xFF684477);
  static const Color cream = Color(0xFFFFFAF5);
  static const Color lavender = Color(0xFFEDE3F5);

  Future<void> sendMessage() async {
    final message = messageController.text.trim();

    if (message.isEmpty || isLoading) return;

    // Save previous messages before adding the new message.
    final conversationHistory = messages.map((item) {
      return {
        'role': item['isUser'] == true ? 'user' : 'assistant',
        'content': item['text'].toString(),
      };
    }).toList();

    setState(() {
      messages.add({
        'text': message,
        'isUser': true,
      });

      isLoading = true;
      messageController.clear();
    });

    scrollToBottom();

    try {
      final result = await aiService.sendMessage(
        message,
        conversationHistory,
      );

      if (!mounted) return;

      setState(() {
        messages.add({
          'text': result['reply'] ?? 'I am here to listen.',
          'isUser': false,
          'emotion': result['detected_emotion'],
          'language': result['response_language'],
        });
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.add({
          'text': 'I could not connect right now. '
              'Please check your internet connection '
              'and try again.',
          'isUser': false,
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        scrollToBottom();
      }
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          color: cream,
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: lavender,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: plum,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MindMate AI',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: plum,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your supportive student companion',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.circle,
                color: Colors.green,
                size: 10,
              ),
              const SizedBox(width: 5),
              const Text(
                'Ready',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_rounded,
                          size: 55,
                          color: plum,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Hey! I am MindMate.',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: plum,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'You can share your thoughts, '
                          'exam stress or anything on your mind. '
                          'Talk to me in your preferred language.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final item = messages[index];
                    final isUser = item['isUser'] == true;

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.78,
                        ),
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUser ? plum : lavender,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['text'].toString(),
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            if (!isUser &&
                                item['emotion'] != null) ...[
                              const SizedBox(height: 7),
                              Text(
                                'Emotion: ${item['emotion']}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: plum,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: plum,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'MindMate is thinking...',
                  style: TextStyle(
                    color: plum,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFEDE3F5)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Share what is on your mind...',
                    filled: true,
                    fillColor: cream,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              IconButton(
                onPressed: isLoading ? null : sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: plum,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

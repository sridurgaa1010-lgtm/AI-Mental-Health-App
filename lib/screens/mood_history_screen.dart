import 'package:flutter/material.dart';
import '../services/mood_service.dart';

class MoodHistoryScreen extends StatelessWidget {
  final bool showAppBar;

  const MoodHistoryScreen({super.key, this.showAppBar = true});

  String formatDate(String date) {
    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null) {
      return 'Date unavailable';
    }

    final now = DateTime.now();

    if (parsedDate.year == now.year &&
        parsedDate.month == now.month &&
        parsedDate.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (parsedDate.year == yesterday.year &&
        parsedDate.month == yesterday.month &&
        parsedDate.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }

  String moodEmoji(String mood) {
    switch (mood) {
      case 'Happy':
        return '😊';
      case 'Calm':
        return '😌';
      case 'Okay':
        return '🙂';
      case 'Sad':
        return '😔';
      case 'Anxious':
        return '😟';
      default:
        return '🌿';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: showAppBar ? AppBar(title: const Text('Mood History')) : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MoodService().getMoodHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final moods = snapshot.data ?? [];

          if (moods.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 55)),
                    const SizedBox(height: 16),
                    const Text(
                      'Your journey starts here',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF684477),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your mood check-ins will appear here. '
                      'Take a moment to record how you feel today.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Your emotional journey',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF684477),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Every feeling deserves to be acknowledged.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ...moods.map((entry) {
                final mood = entry['mood']?.toString() ?? 'Unknown';
                final date = entry['date']?.toString() ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEDE3F5)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFFEDE3F5),
                        child: Text(
                          moodEmoji(mood),
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mood,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF684477),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDate(date),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.favorite_border,
                        color: Color(0xFFB69BC8),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

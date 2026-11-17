import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MoodService {
  static const String _currentMoodKey = 'current_mood';
  static const String _historyKey = 'mood_history';

  // Save a mood and its date.
  Future<void> saveMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();

    final history = await getMoodHistory();

    history.insert(0, {'mood': mood, 'date': DateTime.now().toIso8601String()});

    // Keep the latest 100 entries.
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    await prefs.setString(_currentMoodKey, mood);
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // Get the latest selected mood.
  Future<String?> getMood() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentMoodKey);
  }

  // Get all saved moods, newest first.
  Future<List<Map<String, dynamic>>> getMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_historyKey);

    if (savedData == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(savedData);

      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return [];
    }
  }
}

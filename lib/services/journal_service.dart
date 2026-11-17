import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JournalService {
  static const String _journalKey = 'journal_entries';

  Future<List<Map<String, dynamic>>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_journalKey);

    if (savedData == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(savedData);

      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveEntry({
    required String content,
    required String mood,
  }) async {
    final entries = await getEntries();

    entries.insert(0, {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'content': content,
      'mood': mood,
      'date': DateTime.now().toIso8601String(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_journalKey, jsonEncode(entries));
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();

    entries.removeWhere((entry) => entry['id'] == id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_journalKey, jsonEncode(entries));
  }
}

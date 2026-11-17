import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExamCalmService {
  static const String _tasksKey = 'exam_calm_tasks';

  Future<List<Map<String, dynamic>>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_tasksKey);

    if (savedData == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(savedData);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, jsonEncode(tasks));
  }

  Future<void> addTask({
    required String subject,
    required String topic,
    required int minutes,
  }) async {
    final tasks = await getTasks();

    tasks.insert(0, {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'subject': subject,
      'topic': topic,
      'minutes': minutes,
      'completed': false,
    });

    await saveTasks(tasks);
  }

  Future<void> updateTask(String id, bool completed) async {
    final tasks = await getTasks();

    for (final task in tasks) {
      if (task['id'] == id) {
        task['completed'] = completed;
        break;
      }
    }

    await saveTasks(tasks);
  }

  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task['id'] == id);
    await saveTasks(tasks);
  }
}

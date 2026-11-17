import 'package:shared_preferences/shared_preferences.dart';

class FocusZoneService {
  static const String _sessionsKey = 'focus_completed_sessions';
  static const String _minutesKey = 'focus_total_minutes';

  Future<int> getCompletedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionsKey) ?? 0;
  }

  Future<int> getTotalFocusMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_minutesKey) ?? 0;
  }

  Future<void> recordCompletedSession(int minutes) async {
    final prefs = await SharedPreferences.getInstance();

    final sessions = prefs.getInt(_sessionsKey) ?? 0;
    final totalMinutes = prefs.getInt(_minutesKey) ?? 0;

    await prefs.setInt(_sessionsKey, sessions + 1);
    await prefs.setInt(_minutesKey, totalMinutes + minutes);
  }
}

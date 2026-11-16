import 'package:shared_preferences/shared_preferences.dart';

class MoodService {


  Future<void> saveMood(String mood) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "current_mood",
      mood,
    );

  }



  Future<String?> getMood() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      "current_mood",
    );

  }

}
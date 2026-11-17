
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiChatService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> sendMessage(
    String message,
    List<Map<String, String>> conversationHistory,
  ) async {
    final url = Uri.parse('$baseUrl/chat');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'message': message,
              'conversation_history': conversationHistory,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Unable to connect to Supportify AI: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'welcome_screen.dart';
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  final List<String> languages = const [
    "English",
    "മലയാളം",
    "ಕನ್ನಡ",
    "हिंदी",
    "தமிழ்",
    "తెలుగు",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),

      appBar: AppBar(
        title: const Text("Choose Language"),
        backgroundColor: Colors.teal,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Select your preferred language",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: languages.length,

                itemBuilder: (context, index) {

                  return Card(
                    child: ListTile(
                      title: Text(
                        languages[index],
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                      ),

                      onTap: () {
                        Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WelcomeScreen(
        language: languages[index],
      ),
    ),
  );
},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const Color plum = Color(0xFF684477);
  static const Color cream = Color(0xFFFFFAF5);
  static const Color lavender = Color(0xFFEDE3F5);

  final List<String> languages = const [
    'English',
    'മലയാളം',
    'ಕನ್ನಡ',
    'हिंदी',
    'தமிழ்',
    'తెలుగు',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      appBar: AppBar(
        title: const Text(
          'Choose Language',
          style: TextStyle(
            color: plum,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: cream,
        foregroundColor: plum,
        elevation: 0,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [cream, lavender, cream],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select your preferred language',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: plum,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Choose the language you feel most comfortable with.',
                  style: TextStyle(
                    fontSize: 14,
                    color: plum.withValues(alpha: 0.75),
                  ),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: ListView.builder(
                    itemCount: languages.length,

                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 9,
                          ),

                          title: Text(
                            languages[index],
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: plum,
                            ),
                          ),

                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: plum,
                            size: 19,
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

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    'Your comfort, your language 💜',
                    style: TextStyle(
                      fontSize: 13,
                      color: plum.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final String language;

  const WelcomeScreen({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F2F1),
              Color(0xFF80CBC4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.favorite,
              size: 90,
              color: Colors.teal,
            ),

            const SizedBox(height: 30),

            const Text(
              "Welcome to Supportify",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Your selected language:\n$language",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
               Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          language: language,
        ),
      ),
    );
              },

              child: const Text(
                "Continue",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
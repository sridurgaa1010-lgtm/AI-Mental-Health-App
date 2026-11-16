import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SupportifyApp());
}

class SupportifyApp extends StatelessWidget {
  const SupportifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Supportify",

      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),

      home: const SplashScreen(),
    );
  }
}
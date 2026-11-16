import 'package:flutter/material.dart';
import 'mood_history_screen.dart';
import '../services/mood_service.dart';

class HomeScreen extends StatefulWidget {
  final String language;

  const HomeScreen({
    super.key,
    required this.language,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  final MoodService moodService = MoodService();
  void saveMood(String mood) async {

  await moodService.saveMood(mood);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("$mood saved 🌿"),
    ),
  );

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),

      appBar: AppBar(
        title: const Text("Supportify"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Good Morning 🌿",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "How are you feeling today?",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 20),


            // Mood selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [

                moodButton("😊", "Happy"),

                moodButton("😌", "Calm"),

                moodButton("😐", "Okay"),

                moodButton("😔", "Sad"),

                moodButton("😰", "Anxious"),

              ],
            ),


            const SizedBox(height: 30),


            dashboardCard(
              Icons.edit_note,
              "Journal",
              "Write down your thoughts",
            ),


            dashboardCard(
              Icons.self_improvement,
              "Breathing Exercise",
              "Relax with guided breathing",
            ),


            dashboardCard(
              Icons.chat_bubble_outline,
              "Talk to Supportify AI",
              "Share how you feel",
            ),


            GestureDetector(
  onTap: () {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const MoodHistoryScreen(),
      ),
    );

  },

  child: dashboardCard(
    Icons.show_chart,
    "Mood History",
    "Track your emotional journey",
  ),
),


            dashboardCard(
              Icons.lightbulb_outline,
              "Daily Wellness Tip",
              "Small steps create big changes",
            ),
          ],
        ),
      ),
    );
  }



  Widget moodButton(String emoji, String text) {
    return GestureDetector(

    onTap: () {
      saveMood("$emoji $text");
    },

    child: Column(
      children: [

        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,

          child: Text(
            emoji,
            style: const TextStyle(
              fontSize: 25,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(text),
    
      ],
    ),
    );
  }



  Widget dashboardCard(
      IconData icon,
      String title,
      String subtitle,
      ) {

    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      elevation: 3,

      child: ListTile(

        leading: Icon(
          icon,
          color: Colors.teal,
          size: 35,
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(subtitle),

        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),

      ),
    );
  }
}
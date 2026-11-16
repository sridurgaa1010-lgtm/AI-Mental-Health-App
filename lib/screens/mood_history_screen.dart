import 'package:flutter/material.dart';

class MoodHistoryScreen extends StatelessWidget {
  const MoodHistoryScreen({super.key});


  final List<Map<String, String>> moods = const [

    {
      "date": "Today",
      "mood": "😊 Happy",
    },

    {
      "date": "Yesterday",
      "mood": "😌 Calm",
    },

    {
      "date": "22 July",
      "mood": "😔 Sad",
    },

  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Mood History",
        ),
        backgroundColor: Colors.teal,
      ),


      body: ListView.builder(

        padding: const EdgeInsets.all(20),

        itemCount: moods.length,


        itemBuilder: (context, index) {

          return Card(

            child: ListTile(

              leading: const Icon(
                Icons.calendar_today,
                color: Colors.teal,
              ),


              title: Text(
                moods[index]["date"]!,
              ),


              subtitle: Text(
                moods[index]["mood"]!,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

            ),

          );

        },

      ),

    );

  }
}
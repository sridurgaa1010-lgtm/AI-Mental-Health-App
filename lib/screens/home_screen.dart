
import 'package:flutter/material.dart';
import '../services/mood_service.dart';
import 'mood_history_screen.dart';
import 'journal_screen.dart';
import 'exam_calm_screen.dart';
import 'focus_zone_screen.dart';
import 'mindmate_screen.dart';

class HomeScreen extends StatefulWidget {
  final String language;

  const HomeScreen({super.key, required this.language});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MoodService moodService = MoodService();

  int selectedIndex = 0;
  int historyVersion = 0;
  String? selectedMood;

  static const Color plum = Color(0xFF684477);
  static const Color cream = Color(0xFFFFFAF5);
  static const Color lavender = Color(0xFFEDE3F5);
  static const Color mint = Color(0xFFE1F2E9);

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> saveMood(String mood) async {
    await moodService.saveMood(mood);

    if (!mounted) return;

    setState(() {
      selectedMood = mood;
      historyVersion++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$mood mood saved successfully 🌿'),
        backgroundColor: plum,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void openJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JournalScreen()),
    );
  }

  void openExamCalm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExamCalmScreen()),
    );
  }

  void openFocusZone() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FocusZoneScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            buildHomePage(),
            const MindMateScreen(),
            MoodHistoryScreen(
              key: ValueKey(historyVersion),
              showAppBar: false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: lavender,
        elevation: 4,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_rounded),
            label: 'MindMate',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: lavender,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: plum,
                  size: 27,
                ),
              ),
              const SizedBox(width: 11),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supportify',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: plum,
                    ),
                  ),
                  Text(
                    'Your space to feel better',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const CircleAvatar(
                backgroundColor: mint,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: plum,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Text(
            '${getGreeting()} 🌿',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: plum,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Take a breath. You deserve a moment for yourself.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 25),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF0E7F7),
                  Color(0xFFE5F1E9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A little check-in 💜',
                  style: TextStyle(
                    color: plum,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    color: Color(0xFF665B6C),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    moodOption('😊', 'Happy'),
                    moodOption('😌', 'Calm'),
                    moodOption('🙂', 'Okay'),
                    moodOption('😔', 'Sad'),
                    moodOption('😟', 'Anxious'),
                  ],
                ),
                if (selectedMood != null) ...[
                  const SizedBox(height: 15),
                  Text(
                    'You are feeling $selectedMood today. '
                    'Thank you for checking in!',
                    style: const TextStyle(
                      color: plum,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 27),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: plum,
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A reminder for you',
                        style: TextStyle(
                          color: Color(0xFFE8D8F1),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You do not have to figure everything out today.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFE8C9EE),
                  size: 35,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Your wellbeing space',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: plum,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Small steps can make a difference.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: featureCard(
                  icon: Icons.menu_book_rounded,
                  title: 'My Journal',
                  subtitle: 'Let your thoughts out',
                  color: lavender,
                  onTap: openJournal,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: featureCard(
                  icon: Icons.school_rounded,
                  title: 'Exam Calm',
                  subtitle: 'Manage exam stress',
                  color: const Color(0xFFFFEBD9),
                  onTap: openExamCalm,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: featureCard(
                  icon: Icons.chat_rounded,
                  title: 'MindMate AI',
                  subtitle: 'A space to talk',
                  color: mint,
                  onTap: () {
                    setState(() => selectedIndex = 1);
                  },
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: featureCard(
                  icon: Icons.show_chart_rounded,
                  title: 'Mood History',
                  subtitle: 'See your journey',
                  color: const Color(0xFFE4ECF8),
                  onTap: () {
                    setState(() => selectedIndex = 2);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          InkWell(
            onTap: openFocusZone,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF0EAF2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: lavender,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.timer_rounded,
                      color: plum,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Focus Zone',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: plum,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Focus, take breaks and recharge',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: plum,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              'Made with care, just for you 💜',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget moodOption(String emoji, String mood) {
    final isSelected = selectedMood == mood;

    return GestureDetector(
      onTap: () => saveMood(mood),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: isSelected ? plum : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? plum : Colors.white,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 23),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            mood,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? plum : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 145,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF0EAF2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: plum,
                size: 23,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: plum,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

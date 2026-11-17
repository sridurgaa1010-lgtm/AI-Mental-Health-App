import 'package:flutter/material.dart';
import '../services/exam_calm_service.dart';

class ExamCalmScreen extends StatefulWidget {
  const ExamCalmScreen({super.key});

  @override
  State<ExamCalmScreen> createState() => _ExamCalmScreenState();
}

class _ExamCalmScreenState extends State<ExamCalmScreen> {
  static const Color plum = Color(0xFF684477);
  static const Color cream = Color(0xFFFFFAF5);
  static const Color lavender = Color(0xFFEDE3F5);
  static const Color mint = Color(0xFFE1F2E9);

  final ExamCalmService service = ExamCalmService();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController topicController = TextEditingController();

  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;
  double stressLevel = 3;
  int selectedMinutes = 30;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  void dispose() {
    subjectController.dispose();
    topicController.dispose();
    super.dispose();
  }

  Future<void> loadTasks() async {
    final savedTasks = await service.getTasks();

    if (!mounted) return;

    setState(() {
      tasks = savedTasks;
      isLoading = false;
    });
  }

  Future<void> addTask() async {
    final subject = subjectController.text.trim();
    final topic = topicController.text.trim();

    if (subject.isEmpty || topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both subject and topic.')),
      );
      return;
    }

    await service.addTask(
      subject: subject,
      topic: topic,
      minutes: selectedMinutes,
    );

    subjectController.clear();
    topicController.clear();

    await loadTasks();

    if (!mounted) return;

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Revision task added!'),
        backgroundColor: plum,
      ),
    );
  }

  Future<void> toggleTask(String id, bool completed) async {
    await service.updateTask(id, completed);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await service.deleteTask(id);
    await loadTasks();
  }

  int get completedCount =>
      tasks.where((task) => task['completed'] == true).length;

  String get stressMessage {
    if (stressLevel <= 2) return 'You seem to be feeling quite relaxed.';
    if (stressLevel <= 4)
      return 'A little pressure is okay. Take it one step at a time.';
    if (stressLevel <= 7)
      return 'You may be feeling overwhelmed. Let us slow things down.';
    return 'That sounds like a lot to carry. Pause and focus on one small step.';
  }

  void showCalmActivity(String title, String description, List<String> steps) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: plum,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                ),
                const SizedBox(height: 18),
                ...steps.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: lavender,
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: plum,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plum,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: plum,
        title: const Text(
          'Exam Calm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: plum))
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0E7F7), Color(0xFFE5F1E9)],
                    ),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.spa_rounded, color: plum, size: 34),
                      SizedBox(height: 13),
                      Text(
                        'One step at a time.',
                        style: TextStyle(
                          color: plum,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Exams can feel overwhelming. You do not need '
                        'to do everything at once. Let us make a plan '
                        'that feels manageable.',
                        style: TextStyle(
                          color: Color(0xFF665B6C),
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                sectionTitle('How are you feeling about exams?'),
                const SizedBox(height: 7),
                Text(
                  'Move the slider to check in with yourself.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: whiteCard(),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Stress level'),
                          Text(
                            '${stressLevel.round()} / 10',
                            style: const TextStyle(
                              color: plum,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: stressLevel,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: plum,
                        onChanged: (value) {
                          setState(() => stressLevel = value);
                        },
                      ),
                      Text(
                        stressMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: plum,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                sectionTitle('Take a calming break'),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: calmCard(
                        icon: Icons.air_rounded,
                        title: 'Breathing',
                        subtitle: 'A gentle breathing guide',
                        color: mint,
                        onTap: () => showCalmActivity(
                          'Gentle breathing',
                          'Try this slow breathing exercise. '
                              'Keep it comfortable and do not force your breath.',
                          [
                            'Sit comfortably and relax your shoulders.',
                            'Breathe in gently for 4 counts.',
                            'Breathe out slowly for 6 counts.',
                            'Repeat for a few comfortable rounds.',
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: calmCard(
                        icon: Icons.spa_outlined,
                        title: 'Grounding',
                        subtitle: 'Bring yourself to the present',
                        color: lavender,
                        onTap: () => showCalmActivity(
                          '5–4–3–2–1 grounding',
                          'Notice the world around you, without judging '
                              'what you notice.',
                          [
                            'Name 5 things you can see.',
                            'Notice 4 things you can physically feel.',
                            'Listen for 3 things you can hear.',
                            'Notice 2 things you can smell.',
                            'Name 1 thing you can taste or appreciate.',
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 27),
                sectionTitle('Build your revision plan'),
                const SizedBox(height: 7),
                Text(
                  'Break a big syllabus into smaller tasks.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: whiteCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subject',
                        style: TextStyle(
                          color: plum,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextField(
                        controller: subjectController,
                        decoration: inputDecoration(
                          'e.g. Design and Analysis of Algorithms',
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Topic or chapter',
                        style: TextStyle(
                          color: plum,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextField(
                        controller: topicController,
                        decoration: inputDecoration('e.g. Dynamic Programming'),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Study duration',
                        style: TextStyle(
                          color: plum,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 8,
                        children: [15, 25, 30, 45, 60].map((minutes) {
                          return ChoiceChip(
                            label: Text('$minutes min'),
                            selected: selectedMinutes == minutes,
                            selectedColor: lavender,
                            onSelected: (_) {
                              setState(() => selectedMinutes = minutes);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 17),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: addTask,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add revision task'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: plum,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    sectionTitle('Your revision tasks'),
                    Text(
                      '$completedCount / ${tasks.length} done',
                      style: const TextStyle(
                        color: plum,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (tasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: whiteCard(),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.checklist_rounded,
                          color: plum,
                          size: 35,
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          'Your plan starts with one small task.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: plum,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Add a subject and topic above to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...tasks.map(buildTaskCard),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: plum,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Remember: your worth is not measured by your marks. '
                    'Rest is part of learning, too.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: plum,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  BoxDecoration whiteCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFF0EAF2)),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: cream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget calmCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 145,
        padding: const EdgeInsets.all(14),
        decoration: whiteCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 39,
              width: 39,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: plum),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(color: plum, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskCard(Map<String, dynamic> task) {
    final id = task['id'].toString();
    final completed = task['completed'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: whiteCard(),
      child: Row(
        children: [
          Checkbox(
            value: completed,
            activeColor: plum,
            onChanged: (value) {
              toggleTask(id, value ?? false);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['subject'].toString(),
                  style: TextStyle(
                    color: plum,
                    fontWeight: FontWeight.bold,
                    decoration: completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${task['topic']} • ${task['minutes']} minutes',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => deleteTask(id),
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.grey,
            tooltip: 'Delete task',
          ),
        ],
      ),
    );
  }
}

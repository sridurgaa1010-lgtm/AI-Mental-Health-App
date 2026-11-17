import 'package:flutter/material.dart';
import '../services/journal_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService journalService = JournalService();

  static const Color plum = Color(0xFF684477);
  static const Color cream = Color(0xFFFFFAF5);
  static const Color lavender = Color(0xFFEDE3F5);
  static const Color mint = Color(0xFFE1F2E9);

  List<Map<String, dynamic>> entries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    final savedEntries = await journalService.getEntries();

    if (!mounted) return;

    setState(() {
      entries = savedEntries;
      isLoading = false;
    });
  }

  Future<void> openEditor() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const JournalEditorSheet(),
    );

    if (result == null || !mounted) return;

    await addEntry(result['content']!, result['mood']!);
  }

  Future<void> addEntry(String content, String mood) async {
    try {
      await journalService.saveEntry(content: content, mood: mood);

      await loadEntries();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your journal entry has been saved.'),
          backgroundColor: plum,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save your entry. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await journalService.deleteEntry(id);
      await loadEntries();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete this entry.')),
      );
    }
  }

  String formatDate(String value) {
    final date = DateTime.tryParse(value)?.toLocal();

    if (date == null) return 'Date unavailable';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(date.year, date.month, date.day);

    String dayLabel;

    if (entryDay == today) {
      dayLabel = 'Today';
    } else if (entryDay == today.subtract(const Duration(days: 1))) {
      dayLabel = 'Yesterday';
    } else {
      dayLabel = '${date.day}/${date.month}/${date.year}';
    }

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$dayLabel • $hour:$minute $period';
  }

  Color moodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return const Color(0xFFFFEBD9);
      case 'Calm':
        return mint;
      case 'Sad':
        return const Color(0xFFE4ECF8);
      case 'Anxious':
        return const Color(0xFFF8E5E5);
      default:
        return lavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: plum,
        title: const Text(
          'My Journal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openEditor,
        backgroundColor: plum,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('New entry'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: plum))
          : RefreshIndicator(
              color: plum,
              onRefresh: loadEntries,
              child: entries.isEmpty ? buildEmptyState() : buildEntryList(),
            ),
    );
  }

  Widget buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 65),
        Container(
          height: 105,
          width: 105,
          decoration: BoxDecoration(
            color: lavender,
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(Icons.menu_book_rounded, color: plum, size: 52),
        ),
        const SizedBox(height: 25),
        const Text(
          'Your story starts here',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: plum,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Use this private space to write about your day, '
          'your feelings, your worries, or little wins.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            height: 1.6,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            onPressed: openEditor,
            icon: const Icon(Icons.add),
            label: const Text('Write your first entry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: plum,
              side: const BorderSide(color: plum),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEntryList() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF0E7F7), Color(0xFFE5F1E9)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_outline_rounded, color: plum, size: 30),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Every thought deserves a little space. '
                  'Keep writing at your own pace.',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 23),
        Text(
          'Your entries (${entries.length})',
          style: const TextStyle(
            color: plum,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 13),
        ...entries.map(buildEntryCard),
      ],
    );
  }

  Widget buildEntryCard(Map<String, dynamic> entry) {
    final mood = entry['mood']?.toString() ?? 'Okay';
    final content = entry['content']?.toString() ?? '';
    final id = entry['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: moodColor(mood),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mood,
                  style: const TextStyle(
                    color: plum,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                formatDate(entry['date']?.toString() ?? ''),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
                onSelected: (value) {
                  if (value == 'delete') {
                    deleteEntry(id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete entry')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF423A45),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// Separate widget for the journal editor.
// Its text controller is disposed with this widget.
class JournalEditorSheet extends StatefulWidget {
  const JournalEditorSheet({super.key});

  @override
  State<JournalEditorSheet> createState() => _JournalEditorSheetState();
}

class _JournalEditorSheetState extends State<JournalEditorSheet> {
  static const Color plum = Color(0xFF684477);
  static const Color cream = Color(0xFFFFFAF5);
  static const Color lavender = Color(0xFFEDE3F5);

  final TextEditingController controller = TextEditingController();

  final List<String> moods = ['Happy', 'Calm', 'Okay', 'Sad', 'Anxious'];

  String selectedMood = 'Okay';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void saveEntry() {
    final content = controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first.')),
      );
      return;
    }

    Navigator.of(context).pop({'content': content, 'mood': selectedMood});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          24,
          22,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'A moment for yourself',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: plum,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Write freely. This space is just for you.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
              const SizedBox(height: 23),
              const Text(
                'How are you feeling?',
                style: TextStyle(fontWeight: FontWeight.w600, color: plum),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: moods.map((mood) {
                  final selected = selectedMood == mood;

                  return ChoiceChip(
                    label: Text(mood),
                    selected: selected,
                    selectedColor: lavender,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: plum,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedMood = mood;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              const Text(
                'What is on your mind?',
                style: TextStyle(fontWeight: FontWeight.w600, color: plum),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 7,
                minLines: 5,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText:
                      'Write about your day, your thoughts, '
                      'or anything you want to let out...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: saveEntry,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save my entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: plum,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

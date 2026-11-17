import 'dart:async';
import 'package:flutter/material.dart';
import '../services/focus_zone_service.dart';

class FocusZoneScreen extends StatefulWidget {
  const FocusZoneScreen({super.key});

  @override
  State<FocusZoneScreen> createState() => _FocusZoneScreenState();
}

class _FocusZoneScreenState extends State<FocusZoneScreen> {
  static const Color plum = Color(0xFF684477);
  static const Color cream = Color(0xFFFFFAF5);
  static const Color lavender = Color(0xFFEDE3F5);
  static const Color mint = Color(0xFFE1F2E9);

  final FocusZoneService _service = FocusZoneService();

  Timer? _timer;

  int selectedMinutes = 25;
  int remainingSeconds = 25 * 60;
  int completedSessions = 0;
  int totalFocusMinutes = 0;

  bool isRunning = false;
  bool isBreak = false;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final sessions = await _service.getCompletedSessions();
    final minutes = await _service.getTotalFocusMinutes();

    if (!mounted) return;

    setState(() {
      completedSessions = sessions;
      totalFocusMinutes = minutes;
    });
  }

  void selectDuration(int minutes) {
    if (isRunning) return;

    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = minutes * 60;
      isBreak = false;
    });
  }

  void startTimer() {
    if (isRunning) return;

    if (remainingSeconds <= 0) {
      setState(() {
        remainingSeconds = isBreak ? 5 * 60 : selectedMinutes * 60;
      });
    }

    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          remainingSeconds = 0;
          isRunning = false;
        });

        if (!isBreak) {
          completeFocusSession();
        } else {
          showMessage('Your break is complete. Welcome back!');
        }
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();

    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();

    setState(() {
      isRunning = false;
      isBreak = false;
      remainingSeconds = selectedMinutes * 60;
    });
  }

  Future<void> completeFocusSession() async {
    await _service.recordCompletedSession(selectedMinutes);
    await loadProgress();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Wonderful work! 🎉',
            style: TextStyle(color: plum, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'You completed your focus session. '
            'Take a short break before studying again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                startBreak();
              },
              child: const Text(
                'Start 5-minute break',
                style: TextStyle(color: plum),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Later', style: TextStyle(color: plum)),
            ),
          ],
        );
      },
    );
  }

  void startBreak() {
    _timer?.cancel();

    setState(() {
      isBreak = true;
      remainingSeconds = 5 * 60;
      isRunning = false;
    });

    startTimer();
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: plum,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remaining.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = isBreak ? 5 * 60 : selectedMinutes * 60;

    final progress = totalSeconds == 0
        ? 0.0
        : 1 - (remainingSeconds / totalSeconds);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text(
          'Focus Zone',
          style: TextStyle(color: plum, fontWeight: FontWeight.bold),
        ),
        backgroundColor: cream,
        foregroundColor: plum,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'One task at a time 🌿',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: plum,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Give yourself some quiet time to focus and recharge.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Text(
                    isBreak ? 'BREAK TIME ☕' : 'FOCUS SESSION 🎯',
                    style: const TextStyle(
                      color: plum,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 220,
                    width: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            strokeWidth: 12,
                            backgroundColor: lavender,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              plum,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatTime(remainingSeconds),
                              style: const TextStyle(
                                fontSize: 43,
                                fontWeight: FontWeight.bold,
                                color: plum,
                              ),
                            ),
                            Text(
                              isRunning
                                  ? 'Stay focused'
                                  : isBreak
                                  ? 'Take it easy'
                                  : 'Ready when you are',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (!isBreak) ...[
                    const Text(
                      'Choose your focus duration',
                      style: TextStyle(
                        color: plum,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [15, 25, 45].map((minutes) {
                        final selected = selectedMinutes == minutes;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text('$minutes min'),
                            selected: selected,
                            onSelected: (_) => selectDuration(minutes),
                            selectedColor: lavender,
                            backgroundColor: cream,
                            labelStyle: TextStyle(
                              color: plum,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isRunning ? pauseTimer : startTimer,
                          icon: Icon(
                            isRunning ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(isRunning ? 'Pause' : 'Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: plum,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: resetTimer,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: plum,
                          side: const BorderSide(color: lavender),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Your focus journey',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: plum,
              ),
            ),
            const SizedBox(height: 13),

            Row(
              children: [
                Expanded(
                  child: progressCard(
                    Icons.check_circle_outline_rounded,
                    '$completedSessions',
                    'Sessions completed',
                    lavender,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: progressCard(
                    Icons.access_time_rounded,
                    '$totalFocusMinutes',
                    'Focus minutes',
                    mint,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(21),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.air_rounded, color: plum, size: 25),
                      SizedBox(width: 9),
                      Text(
                        'Need a moment to breathe?',
                        style: TextStyle(
                          color: plum,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Try a gentle guided breathing exercise '
                    'before your next study session.',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const BreathingExerciseSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plum,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start breathing exercise'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget progressCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: plum, size: 25),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: plum,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: plum, fontSize: 11)),
        ],
      ),
    );
  }
}

// Guided breathing exercise

class BreathingExerciseSheet extends StatefulWidget {
  const BreathingExerciseSheet({super.key});

  @override
  State<BreathingExerciseSheet> createState() => _BreathingExerciseSheetState();
}

class _BreathingExerciseSheetState extends State<BreathingExerciseSheet> {
  static const Color plum = Color(0xFF684477);
  static const Color cream = Color(0xFFFFFAF5);
  static const Color lavender = Color(0xFFEDE3F5);

  final List<String> phases = [
    'Breathe in',
    'Hold gently',
    'Breathe out',
    'Relax',
  ];

  int phaseIndex = 0;
  int seconds = 4;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        seconds--;

        if (seconds <= 0) {
          phaseIndex = (phaseIndex + 1) % phases.length;
          seconds = 4;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpanding = phaseIndex == 0;

    return Container(
      height: 440,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: lavender,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'A moment for yourself',
            style: TextStyle(
              color: plum,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow the gentle rhythm. There is no need to rush.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(seconds: 3),
                curve: Curves.easeInOut,
                height: isExpanding ? 175 : 135,
                width: isExpanding ? 175 : 135,
                decoration: BoxDecoration(
                  color: lavender,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: plum.withValues(alpha: 0.12),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$seconds',
                      style: const TextStyle(
                        color: plum,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      phases[phaseIndex],
                      style: const TextStyle(
                        color: plum,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),
          const Text(
            'Continue at your own comfortable pace.',
            style: TextStyle(color: plum, fontSize: 12),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: plum,
                padding: const EdgeInsets.all(14),
              ),
              child: const Text('Finish exercise'),
            ),
          ),
        ],
      ),
    );
  }
}

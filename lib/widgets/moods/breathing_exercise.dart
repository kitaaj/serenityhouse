import 'package:flutter/material.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final _phases = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  int _currentPhase = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextPhase();
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _nextPhase();
        _controller.forward();
      }
    });
    _controller.forward();
  }

  void _nextPhase() {
    setState(() {
      _currentPhase = (_currentPhase + 1) % _phases.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder:
                  (context, child) => Container(
                    width: 200 * _controller.value,
                    height: 200 * _controller.value,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
            ),
            const SizedBox(height: 40),
            Text(
              _phases[_currentPhase],
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

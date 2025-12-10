// lib/features/timer/presentation/session_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_work_sessions/features/timer/application/timer_notifier.dart';
import '../domain/timer_state.dart';
import '../../application/application_providers.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours > 0 ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTask = ref.watch(activeTaskProvider);
    final timerState = ref.watch(timerNotifierProvider);
    final timerNotifier = ref.read(timerNotifierProvider.notifier);
    final genericSettings = ref.watch(genericTimerSettingsProvider);

    final isRunning = timerState.status == TimerStatus.running;
    final double progress = timerState.mode == TimerMode.pomodoro && timerState.initialDuration.inSeconds > 0
        ? timerState.duration.inSeconds / timerState.initialDuration.inSeconds
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Session de Focus')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (activeTask == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SegmentedButton<TimerMode>(
                    segments: const [
                      ButtonSegment(value: TimerMode.pomodoro, label: Text('Pomodoro'), icon: Icon(Icons.av_timer)),
                      ButtonSegment(value: TimerMode.stopwatch, label: Text('Chronomètre'), icon: Icon(Icons.timer_outlined)),
                    ],
                    selected: {genericSettings.mode},
                    onSelectionChanged: (newSelection) {
                      ref.read(genericTimerSettingsProvider.notifier).state = GenericTimerSettings(mode: newSelection.first, pomodoroDuration: genericSettings.pomodoroDuration);
                    },
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250, height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(value: 1, color: Theme.of(context).scaffoldBackgroundColor, strokeWidth: 12),
                    if (timerState.mode == TimerMode.pomodoro)
                      CircularProgressIndicator(value: progress, strokeWidth: 12, strokeCap: StrokeCap.round)
                    else
                      CircularProgressIndicator(value: 1, strokeWidth: 4),
                    Center(child: Text(_formatDuration(timerState.duration), style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (activeTask == null && genericSettings.mode == TimerMode.pomodoro)
                _CustomDurationInput(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(child: Align(alignment: Alignment.centerLeft, child: activeTask != null ? IconButton(icon: const Icon(Icons.eject_outlined), onPressed: timerNotifier.detachTask, tooltip: 'Quitter la tâche') : const SizedBox(width: 48))),
                    FloatingActionButton.extended(
                      onPressed: isRunning ? timerNotifier.pause : timerNotifier.start,
                      icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40),
                      label: Text(isRunning ? 'PAUSE' : 'DÉMARRER'),
                    ),
                    Expanded(child: Align(alignment: Alignment.centerRight, child: IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: timerNotifier.reset, tooltip: 'Réinitialiser'))),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  activeTask != null ? "Tâche en cours: ${activeTask.title}" : (genericSettings.mode == TimerMode.pomodoro ? "Session Pomodoro" : "Chronomètre"),
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomDurationInput extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CustomDurationInput> createState() => __CustomDurationInputState();
}

class __CustomDurationInputState extends ConsumerState<_CustomDurationInput> {
  final _minutesController = TextEditingController();

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _applyCustomDuration() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    if (minutes > 0) {
      ref.read(genericTimerSettingsProvider.notifier).state = GenericTimerSettings(
        mode: TimerMode.pomodoro,
        pomodoroDuration: Duration(minutes: minutes),
      );
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Durée:"),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _minutesController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "min"),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _applyCustomDuration,
            tooltip: "Appliquer la durée",
          )
        ],
      ),
    );
  }
}

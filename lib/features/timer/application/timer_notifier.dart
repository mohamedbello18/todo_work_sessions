// lib/features/timer/application/timer_notifier.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_work_sessions/data/models/task.dart';
import 'package:todo_work_sessions/features/application/application_providers.dart';
import '../domain/timer_state.dart';

@immutable
class GenericTimerSettings {
  final TimerMode mode;
  final Duration pomodoroDuration;
  const GenericTimerSettings({this.mode = TimerMode.pomodoro, this.pomodoroDuration = const Duration(minutes: 25)});
}

final genericTimerSettingsProvider = StateProvider<GenericTimerSettings>((ref) => const GenericTimerSettings());

class TimerNotifier extends StateNotifier<TimerState> {
  final Ref _ref;
  Timer? _timer;

  TimerNotifier(this._ref) : super(TimerState(duration: _ref.read(genericTimerSettingsProvider).pomodoroDuration, initialDuration: _ref.read(genericTimerSettingsProvider).pomodoroDuration, status: TimerStatus.initial));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void start() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.mode == TimerMode.pomodoro) {
        if (state.duration.inSeconds > 0) {
          state = state.copyWith(duration: state.duration - const Duration(seconds: 1));
        } else {
          _timer?.cancel();
          state = state.copyWith(status: TimerStatus.finished);
        }
      } else {
        state = state.copyWith(duration: state.duration + const Duration(seconds: 1));
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void reset() {
    _timer?.cancel();
    final newDuration = state.mode == TimerMode.pomodoro ? state.initialDuration : Duration.zero;
    state = state.copyWith(duration: newDuration, status: TimerStatus.initial);
  }

  void detachTask() {
    _ref.read(activeTaskProvider.notifier).state = null;
  }

  void configureTimer({Task? task}) {
    _timer?.cancel();
    final genericSettings = _ref.read(genericTimerSettingsProvider);
    if (task != null) {
      if (task.estimatedDuration != null) {
        state = TimerState(duration: task.estimatedDuration!, initialDuration: task.estimatedDuration!, mode: TimerMode.pomodoro, status: TimerStatus.initial);
      } else {
        state = const TimerState(duration: Duration.zero, initialDuration: Duration.zero, mode: TimerMode.stopwatch, status: TimerStatus.initial);
      }
    } else {
      if (genericSettings.mode == TimerMode.pomodoro) {
        state = TimerState(duration: genericSettings.pomodoroDuration, initialDuration: genericSettings.pomodoroDuration, mode: TimerMode.pomodoro, status: TimerStatus.initial);
      } else {
        state = const TimerState(duration: Duration.zero, initialDuration: Duration.zero, mode: TimerMode.stopwatch, status: TimerStatus.initial);
      }
    }
  }
}

final timerNotifierProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final notifier = TimerNotifier(ref);
  ref.listen<Task?>(activeTaskProvider, (prev, next) => notifier.configureTimer(task: next));
  ref.listen<GenericTimerSettings>(genericTimerSettingsProvider, (prev, next) {
    if (ref.read(activeTaskProvider) == null) {
      notifier.configureTimer();
    }
  });
  return notifier;
});

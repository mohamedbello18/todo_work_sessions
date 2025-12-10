// lib/features/timer/domain/timer_state.dart

import 'package:flutter/foundation.dart';

/// Définit le type de session en cours (Pomodoro).
enum SessionType {
  focus('Focus'),
  shortBreak('Pause Courte'),
  longBreak('Pause Longue');

  const SessionType(this.displayName);
  final String displayName;
}

/// Définit l'état d'exécution du minuteur.
enum TimerStatus {
  initial, running, paused, finished
}

/// Définit le mode de fonctionnement du minuteur.
enum TimerMode {
  pomodoro,  // Compte à rebours
  stopwatch, // Compte à partir de zéro
}


@immutable
class TimerState {
  /// La durée restante (pomodoro) ou écoulée (stopwatch).
  final Duration duration;

  /// Le statut actuel (en cours, en pause, etc.).
  final TimerStatus status;

  /// Le type de session (focus, pause...).
  final SessionType sessionType;

  /// Le mode de fonctionnement.
  final TimerMode mode;

  /// La durée initiale pour le mode pomodoro (utile pour le calcul de la progression).
  final Duration initialDuration;

  const TimerState({
    required this.duration,
    required this.status,
    this.sessionType = SessionType.focus,
    this.mode = TimerMode.pomodoro,
    required this.initialDuration,
  });

  TimerState copyWith({
    Duration? duration,
    TimerStatus? status,
    SessionType? sessionType,
    TimerMode? mode,
    Duration? initialDuration,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      status: status ?? this.status,
      sessionType: sessionType ?? this.sessionType,
      mode: mode ?? this.mode,
      initialDuration: initialDuration ?? this.initialDuration,
    );
  }
}

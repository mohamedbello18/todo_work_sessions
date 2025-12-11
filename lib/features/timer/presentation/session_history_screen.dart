import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:todo_work_sessions/data/models/session.dart';
import 'package:todo_work_sessions/data/models/task.dart';

final sessionStreamProvider = StreamProvider<List<Session>>((ref) async* {
  final box = Hive.box<Session>('sessionsBox');
  yield box.values.toList();
  yield* box.watch().map((event) => box.values.toList());
});

class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({super.key});

  String _formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, '0');
  }

  void _deleteSession(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la session'),
        content: const Text('Voulez-vous vraiment supprimer cette session ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              session.delete();
              Navigator.of(ctx).pop();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Vider l'historique"),
        content: const Text('Voulez-vous vraiment supprimer toutes les sessions enregistrées ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Hive.box<Session>('sessionsBox').clear();
              Navigator.of(ctx).pop();
            },
            child: const Text('Tout supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionStreamProvider);
    final tasksBox = Hive.box<Task>('tasksBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _clearHistory(context),
            tooltip: "Vider l'historique",
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('Aucune session enregistrée.'));
          }
          sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final task = session.taskKey != null ? tasksBox.get(session.taskKey) : null;

              final startTime = DateFormat.Hms('fr_FR').format(session.startTime);
              final endTime = session.endTime != null ? DateFormat.Hms('fr_FR').format(session.endTime!) : 'en cours';
              final date = DateFormat.yMMMd('fr_FR').format(session.startTime);

              return ListTile(
                leading: Icon(session.sessionType == RecordedSessionType.task ? Icons.article : Icons.person),
                title: Text(
                  session.sessionType == RecordedSessionType.task 
                  ? task?.title ?? 'Tâche supprimée' 
                  : 'Session Personnelle',
                ),
                subtitle: Text('Le $date, de $startTime à $endTime'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_formatDuration(session.duration), style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _deleteSession(context, session),
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

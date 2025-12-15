import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/todo_list_provider.dart';

class Session extends StatelessWidget {
  const Session({super.key});

  @override
  Widget build(BuildContext context) {
    // Utiliser Consumer pour écouter les changements
    return Consumer<TodoListProvider>(
      builder: (context, todoProvider, child) {
        final todos = todoProvider.todos;
        final pendingTodos = todos.where((t) => !t.accompli).toList();
        final completedTodos = todos.where((t) => t.accompli).toList();
        
        // Regroupement par type
        final Map<TodoType, int> typeCounts = {};
        for (var todo in pendingTodos) {
          typeCounts.update(todo.type, (value) => value + 1, ifAbsent: () => 1);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tableau de Bord des Tâches',style: TextStyle(color: Colors.black,fontSize:17,fontWeight: FontWeight.w600),),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Statistiques Clés (Widgets de type Card/résumé)
                Row(
                  children: [
                    _buildStatCard('Total Tâches', todos.length, Colors.blue),
                    const SizedBox(width: 10),
                    _buildStatCard('En Attente', pendingTodos.length, Colors.red),
                    const SizedBox(width: 10),
                    _buildStatCard('Terminées', completedTodos.length, Colors.green),
                  ],
                ),
                const Divider(height: 30),

                // 2. Tâches Urgentes / En Retard
                Text(
                  '🚨 Tâches Urgentes (Échéance Aujourd\'hui ou Passée)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildUrgentList(pendingTodos, context),
                const Divider(height: 30),

                // 3. Répartition par Type
                Text(
                  '📊 Répartition des Tâches En Attente par Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildTypeBreakdown(typeCounts),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget pour les cartes de statistiques
  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(count.toString(), style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // Liste des tâches urgentes
  Widget _buildUrgentList(List<Todo> todos, BuildContext context) {
    final now = DateTime.now();
    final urgent = todos.where((t) => t.realisation.isBefore(now.add(const Duration(hours: 24)))).toList();
    
    if (urgent.isEmpty) {
      return const Text('Aucune tâche urgente pour le moment !');
    }

    return Column(
      children: urgent.map((todo) {
        return ListTile(
          leading: Icon(todo.iconData, color: Colors.red.shade700),
          title: Text(todo.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            'Échéance: ${DateFormat('dd MMM à HH:mm', 'fr').format(todo.realisation)}',
            style: TextStyle(color: todo.realisation.isBefore(now) ? Colors.red : Colors.orange),
          ),
          // Ajoutez onTap pour naviguer vers la modification si vous voulez
        );
      }).toList(),
    );
  }

  // Répartition par Type (Tableau)
  Widget _buildTypeBreakdown(Map<TodoType, int> typeCounts) {
    if (typeCounts.isEmpty) {
      return const Text('Aucune tâche en attente à classer.');
    }
    
    // Convertir la carte en une liste de widgets pour l'affichage
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFE3F2FD)), // Light Blue background
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(8), child: Text('Tâches', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
          ],
        ),
        ...typeCounts.entries.map((entry) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(getIconForType(entry.key), size: 18, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(getNameForType(entry.key)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(entry.value.toString(), textAlign: TextAlign.right),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}
// page/accueil.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/page/ajout_modification.dart';

import '../models/todo.dart';
import '../providers/todo_list_provider.dart';

class Accueil extends StatelessWidget {
  const Accueil({super.key});

  // Fonction pour afficher la boîte de dialogue de confirmation de suppression
  Future<void> _confirmDelete(BuildContext context, Todo todo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Êtes-vous sûr de vouloir supprimer la tâche : "${todo.titre}" ?'),
                const Text('Cette action est irréversible.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Supprimer la tâche
                Provider.of<TodoListProvider>(context, listen: false)
                    .deleteTodo(todo.id);
                
                // Afficher la Snackbar de notification de suppression
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('La tâche "${todo.titre}" a été supprimée.'),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
                
                Navigator.of(dialogContext).pop(); 
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),),
        backgroundColor: Colors.transparent,
      ),
      body: todoProvider.todos.isEmpty
          ? const Center(child: Text("Aucune tâche. Ajoutez-en une !"))
          : ListView.builder(
              itemCount: todoProvider.todos.length,
              itemBuilder: (context, index) {
                final todo = todoProvider.todos[index];
                return _buildTodoCard(context, todo);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AjoutModification(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget pour construire chaque carte de tâche
  Widget _buildTodoCard(BuildContext context, Todo todo) {
    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm', 'fr');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: todo.accompli ? Colors.green.shade50 : Colors.white,
      child: ListTile(
        leading: Icon(
          todo.iconData,
          color: todo.accompli ? Colors.green : Colors.blue,
          size: 40,
        ),
        title: Text(
          todo.titre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: todo.accompli
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${getNameForType(todo.type)}',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700),
            ),
            Text(
              todo.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Échéance: ${formatter.format(todo.realisation)}',
              style: TextStyle(
                fontSize: 12,
                color: todo.realisation.isBefore(DateTime.now()) && !todo.accompli
                    ? Colors.red
                    : Colors.grey.shade700,
                fontWeight: todo.realisation.isBefore(DateTime.now()) && !todo.accompli
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton pour marquer comme accompli/non accompli (MODIFIÉ)
            IconButton(
              icon: Icon(
                todo.accompli ? Icons.check_circle : Icons.circle_outlined,
                color: todo.accompli ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                // Déterminer l'état actuel pour le message
                final bool wasCompleted = todo.accompli;
                final String action = wasCompleted ? 'remise en attente' : 'accomplie';
                final Color snackBarColor = wasCompleted ? Colors.orange.shade400 : Colors.green.shade400;

                // 1. Appeler le toggle pour changer l'état
                Provider.of<TodoListProvider>(context, listen: false)
                    .toggleTodoStatus(todo.id);
                
                // 2. Afficher la Snackbar de confirmation d'action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tâche "${todo.titre}" ${action} !'),
                    backgroundColor: snackBarColor,
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              },
            ),
            // Bouton de suppression
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, todo),
            ),
          ],
        ),
        onTap: () {
          // Naviguer vers la page de modification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjoutModification(todo: todo),
            ),
          );
        },
      ),
    );
  }
}
// providers/todo_list_provider.dart

import 'package:flutter/material.dart';
import '../models/todo.dart'; // Assurez-vous du bon chemin

class TodoListProvider extends ChangeNotifier {
  // Liste interne des tâches
  final List<Todo> _todos = [
    // Exemple initial
    Todo(
      id: 1,
      titre: "Faire les courses",
      description: "Acheter du pain, du lait et des œufs.",
      type: TodoType.courses,
      realisation: DateTime.now().add(const Duration(days: 1)),
    ),
    Todo(
      id: 2,
      titre: "Rendez-vous dentiste",
      description: "Contrôle annuel à 10h00.",
      type: TodoType.evenement,
      realisation: DateTime.now().add(const Duration(days: 3)),
      accompli: true,
    ),
  ];

  List<Todo> get todos => _todos;

  void addTodo(String titre, String description, TodoType type, DateTime realisation) {
    final newId = _todos.isEmpty ? 1 : _todos.last.id + 1;
    final newTodo = Todo(
      id: newId,
      titre: titre,
      description: description,
      type: type,
      realisation: realisation,
    );
    _todos.add(newTodo);
    notifyListeners();
  }

  void updateTodo(Todo updatedTodo) {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo.copyWith(updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  void toggleTodoStatus(int id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].accompli = !_todos[index].accompli;
      _todos[index].updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  void deleteTodo(int id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }
}
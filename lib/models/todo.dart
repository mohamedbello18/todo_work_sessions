// models/todo.dart

import 'package:flutter/material.dart';

// Énumération des types de tâches
enum TodoType { travail, maison, courses, etude, sport, evenement }

// Fonction utilitaire pour obtenir l'icône à partir du type
IconData getIconForType(TodoType type) {
  switch (type) {
    case TodoType.travail:
      return Icons.work;
    case TodoType.maison:
      return Icons.home;
    case TodoType.courses:
      return Icons.shopping_cart;
    case TodoType.etude:
      return Icons.school;
    case TodoType.sport:
      return Icons.fitness_center;
    case TodoType.evenement:
      return Icons.event_note;
  }
}

// Fonction utilitaire pour obtenir le nom affichable
String getNameForType(TodoType type) {
  switch (type) {
    case TodoType.travail:
      return "Travail";
    case TodoType.maison:
      return "Maison";
    case TodoType.courses:
      return "Courses";
    case TodoType.etude:
      return "Étude";
    case TodoType.sport:
      return "Sport";
    case TodoType.evenement:
      return "Rendez-vous";
  }
}

class Todo {
  final int id;
  String titre;
  String description;
  TodoType type; // Utilisation du type
  bool accompli;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime realisation;

  Todo({
    required this.id, 
    required this.titre,
    required this.description,
    this.type = TodoType.evenement,
    this.accompli = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.realisation,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Getter pour l'icône
  IconData get iconData => getIconForType(type);
  
  // Méthode pour copier une tâche (utile pour les mises à jour)
  Todo copyWith({
    int? id,
    String? titre,
    String? description,
    TodoType? type, 
    bool? accompli,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? realisation,
  }) {
    return Todo(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      type: type ?? this.type,
      accompli: accompli ?? this.accompli,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      realisation: realisation ?? this.realisation,
    );
  }
}
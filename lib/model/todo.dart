class Todo {
  int id = 1;
  String titre;
  String description;
  bool accompli;
  DateTime createdAt;
  DateTime updatedAt;

  Todo({
    int? id,
    required this.titre,
    required this.description,
    this.accompli = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  void addTodo(String titre, String description, DateTime realisation) {
    id++;
    this.titre = titre;
    this.description = description;
  }

  void updateTodo(int id, String titre, String description, DateTime realisation) {
    this.titre = titre;
    this.description = description;
    updatedAt = DateTime.now();
  }
}

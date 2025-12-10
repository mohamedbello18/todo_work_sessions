class Step {
  int todoId;
  String detail;
  bool complete;
  DateTime createdAt;
  DateTime updatedAt;

  Step({
    required this.todoId,
    required this.detail,
    this.complete = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  void addStep(int todoId, String detail) {
    this.todoId = todoId;
    this.detail = detail;
  }

  void updateStep(String detail) {
    this.detail = detail;
    updatedAt = DateTime.now();
  }
}

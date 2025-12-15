// models/user.dart

class User {
  final String id;
  String username;
  String email;
  // Vous pouvez ajouter d'autres champs ici (nom, photo, etc.)

  User({
    required this.id,
    required this.username,
    required this.email,
  });

  // Méthode pour la mise à jour des informations
  User copyWith({
    String? username,
    String? email,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}
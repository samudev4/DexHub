// ignore_for_file: strict_top_level_inference

class UserModel {
  final String uid;
  final String email;
  final String? name;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
  });

  // 🔄 Crear desde Firestore
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      name: data['name'] as String?,
    );
  }

  // 🔄 Crear desde FirebaseAuth (fallback)
  factory UserModel.fromFirebaseUser(dynamic user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
    );
  }

  // 📤 Enviar a Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      if (name != null) 'name': name, // 👈 NO guardamos ''
    };
  }

  // ✨ CLAVE: actualizar campos sin romper el objeto
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}


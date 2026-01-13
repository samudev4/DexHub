// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro con Firestore
  Future<UserModel?> register(String email, String password, {String? name}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Crear documento en Firestore
        UserModel newUser = UserModel(uid: user.uid, email: email, name: name);
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Login y obtención de datos desde Firestore
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Leer datos desde Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Stream de usuario desde Firebase Auth (opcional)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getUserFromFirestore(String uid) async {
  final doc = await _firestore.collection('users').doc(uid).get();
  if (!doc.exists || doc.data() == null) return null;

  return UserModel.fromMap(doc.data()!);
}


}

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserName(String newName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEmail(String newEmail) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'email': newEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}


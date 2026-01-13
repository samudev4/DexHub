import 'package:dexhub/controllers/favorites_controller.dart';
import 'package:dexhub/models/user_model.dart';
import 'package:dexhub/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? user;
  bool initialized = false;
  final UserService _userService = UserService();
  final FavoritesController favoritesController;

  AuthController(this.favoritesController) {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        user = await _authService.getUserFromFirestore(firebaseUser.uid);
        favoritesController.startListening(); // 👈
      } else {
        user = null;
        favoritesController.stopListening(); // 👈
      }
      initialized = true;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      final userData = await _authService.login(email, password);
      if (userData != null) {
        user = userData;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(String email, String password, {String? name}) async {
    final newUser = await _authService.register(email, password, name: name);
    if (newUser != null) {
      user = newUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }

  Future<bool> updateName(String newName) async {
    try {
      await _userService.updateUserName(newName);
      if (user != null) {
        user = user!.copyWith(name: newName); // 🔑 actualizar modelo en memoria
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateEmail(String newEmail) async {
    try {
      await _userService.updateEmail(newEmail);
      if (user != null) {
        user = user!.copyWith(
          email: newEmail,
        ); // 🔑 actualizar modelo en memoria
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

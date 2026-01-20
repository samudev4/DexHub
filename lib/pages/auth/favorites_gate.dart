import 'package:dexhub/controllers/auth_controller.dart';
import 'package:dexhub/pages/auth/login_required_page.dart';
import 'package:dexhub/pages/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesGate extends StatelessWidget {
  const FavoritesGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.user == null) {
      return const LoginRequiredPage(
        title: "Favoritos",
        message: "Crea una cuenta o inicia sesión para guardar y sincronizar tus favoritos.",
      );
    }

    return const FavoritesPage();
  }
}

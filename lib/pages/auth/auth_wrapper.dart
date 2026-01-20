import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/controllers/auth_controller.dart';
import 'package:dexhub/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (!authController.initialized) {
      return Scaffold(
        backgroundColor: AppColors.colorFondoScaffold(context),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.colorTexto(context),
          ),
        ),
      );
    }

    /// ✅ Siempre entra a HomePage
    /// - si user == null → invitado
    /// - si user != null → logueado
    return HomePage();
  }
}

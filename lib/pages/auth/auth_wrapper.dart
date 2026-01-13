import 'package:dexhub/controllers/auth_controller.dart';
import 'package:dexhub/pages/auth/welcome_page.dart';
import 'package:dexhub/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    if (!authController.initialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authController.user != null) {
      return HomePage();
    } else {
      return WelcomePage();
    }
  }
}

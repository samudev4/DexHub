import 'package:dexhub/controllers/auth_controller.dart';
import 'package:dexhub/pages/account/account_page.dart';
import 'package:dexhub/pages/auth/login_required_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountGate extends StatelessWidget {
  const AccountGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.user == null) {
      return const LoginRequiredPage(
        title: "Cuenta",
        message: "Crea una cuenta o inicia sesión para acceder a tu cuenta y ajustes.",
      );
    }

    return const AccountPage();
  }
}

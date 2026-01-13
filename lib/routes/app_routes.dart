import 'package:dexhub/pages/auth/auth_wrapper.dart';
import 'package:dexhub/pages/auth/login_page.dart';
import 'package:dexhub/pages/auth/register_page.dart';
import 'package:dexhub/pages/auth/welcome_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  // Nombres de rutas (constantes)
  static const String authWrapper = '/auth_wrapper';
  static const String loginPage = '/login_page';
  static const String registerPage = '/register_page';
  static const String welcomePage = '/welcome_page';

  // Ruta inicial
  static const String initialRoute = welcomePage;

  // Mapa de rutas
  static final Map<String, WidgetBuilder> routes = {
    loginPage: (context) => const LoginPage(),
    registerPage: (context) => const RegisterPage(),
    welcomePage: (context) => const WelcomePage(),
    authWrapper: (context) => AuthWrapper(),
  };
}

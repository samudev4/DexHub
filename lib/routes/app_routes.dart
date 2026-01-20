import 'package:dexhub/pages/auth/auth_wrapper.dart';
import 'package:dexhub/pages/auth/login_page.dart';
import 'package:dexhub/pages/auth/register_page.dart';
import 'package:dexhub/pages/home_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  // Nombres de rutas (constantes)
  static const String authWrapper = '/auth_wrapper';
  static const String loginPage = '/login_page';
  static const String registerPage = '/register_page';
  static const String welcomePage = '/welcome_page';
  static const String homePage = "/home";

  // Ruta inicial
  static const String initialRoute = authWrapper;

  // Mapa de rutas
  static final Map<String, WidgetBuilder> routes = {
    loginPage: (context) => const LoginPage(),
    registerPage: (context) => const RegisterPage(),
    authWrapper: (context) => AuthWrapper(),
    homePage: (context) => HomePage(),
  };
}

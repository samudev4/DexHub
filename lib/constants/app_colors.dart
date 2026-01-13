import 'package:dexhub/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppColors {
  static Color colorTexto(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? Color(0xFFE3E3E3) : Color(0xFF1F1F1F);
  }

  static Color colorFondoScaffold(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFFFFFF);
  }

  static Color colorFondoAppBar(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFFFFFF);
  }

  static Color colorFondoNavigationBar(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? const Color(0xFF1E1F20) : const Color(0XFFF0F4F9);
  }

  static Color colorTextoPantallasPrincipales(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  static Color colorFondoBoton(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? const Color(0xFF173EA5) : const Color(0xFF173EA5);
  }

  static Color colorHintText(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? const Color(0xFF999999) : const Color(0xFF999999);
  }

  static Color colorFondoActions(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);
  }

  static Color colorTextoSecundarioAuth(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? const Color(0xFF999999) : const Color(0xFF666666);
  }

  static Color colorTituloSecundarioAuth(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return isDark ? const Color(0xFFB2B2B2) : const Color(0xFF4D4D4D);
  }


  /// ⚙️ Colores fijos (no dependen del tema)
  //static const Color success = Color(0xFF4CAF50);
  //static const Color warning = Color(0xFFFFC107);
  //static const Color error = Color(0xFFF44336);
}

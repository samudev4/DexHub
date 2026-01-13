// ignore_for_file: use_key_in_widget_constructors

import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:dexhub/controllers/auth_controller.dart';
import 'package:dexhub/controllers/favorites_controller.dart';
import 'package:dexhub/firebase_options.dart';
import 'package:dexhub/routes/app_routes.dart';
import 'package:dexhub/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// 🔴 FAVORITOS (vive siempre)
        ChangeNotifierProvider(create: (_) => FavoritesController()),

        /// 🔐 AUTH (depende de favoritos)
        ChangeNotifierProxyProvider<FavoritesController, AuthController>(
          create: (context) =>
              AuthController(context.read<FavoritesController>()),
          update: (_, favoritesController, authController) => authController!,
        ),

        ChangeNotifierProvider(create: (_) => ThemeProvider(), child: MyApp()),
      ],
      child: ToastificationWrapper(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.textoNombreApp,
          initialRoute: AppRoutes.authWrapper,
          routes: AppRoutes.routes,
        ),
      ),
    );
  }
}

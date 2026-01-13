// ignore_for_file: use_build_context_synchronously

import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:dexhub/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;
  bool _obscureText = true;

  void _login(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => loading = true);

    bool success = await authController.login(email, password);

    setState(() => loading = false);

    if (success) {
      toastification.show(
        title: Text(AppStrings.textoBienvenidoDeNuevo),
        description: Text(AppStrings.textoQueAlegriaVolverAVerte),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: Duration(seconds: 3),
        showProgressBar: true,
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    } else {
      toastification.show(
        title: Text(AppStrings.textoErrorAlIniciarSesion),
        description: Text(AppStrings.textoAlgoNoHaSalidoComoDeberia),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: Duration(seconds: 3),
        showProgressBar: true,
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondoScaffold(context),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.colorFondoAppBar(context),
        leading: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.colorTexto(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          AppStrings.textoIniciarSesion,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.colorTexto(context),
          ),
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 45),
                Text(
                  textAlign: TextAlign.center,
                  AppStrings.textoBienvenidoDeNuevo,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: AppColors.colorTituloSecundarioAuth(context),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  textAlign: TextAlign.center,
                  AppStrings.textoIntroduceTusDatos,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.colorTexto(context),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.textoEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Container(
                    height: 58,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF999999), width: 2),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: TextField(
                        controller: emailController,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: AppStrings.textoEmail,
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.colorHintText(context),
                          ),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Icon(
                              Ionicons.mail_outline,
                              color: AppColors.colorTexto(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.textoContrasena,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Container(
                    height: 58,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF999999), width: 2),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: TextField(
                          controller: passwordController,
                          obscureText: _obscureText,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: AppColors.colorTexto(context),
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: AppStrings.textoContrasena,
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.colorHintText(context),
                            ),
                            border: InputBorder.none,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Icon(
                                Ionicons.key_outline,
                                color: AppColors.colorTexto(context),
                              ),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText
                                    ? Ionicons.eye_outline
                                    : Ionicons.eye_off_outline,
                                color: AppColors.colorTexto(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                /*
                SizedBox(height: 26),
                Text(
                  AppStrings.textoOlvidasteTuContrasena,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.colorFondoBoton(context),
                  ),
                ),
                */
                SizedBox(height: 38),
                loading
                    ? CircularProgressIndicator()
                    : GestureDetector(
                        onTap: () async {
                          _login(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Container(
                            height: 68,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: AppColors.colorFondoBoton(context),
                            ),
                            child: Center(
                              child: Text(
                                AppStrings.textoIniciarSesion,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

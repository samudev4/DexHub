import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:dexhub/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondoScaffold(context),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset(AppStrings.rutaImagenBienvenida)),
            SizedBox(height: 39),
            Text(
              textAlign: TextAlign.center,
              AppStrings.textoPreparadoParaLaAventura,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: AppColors.colorTexto(context),
              ),
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.center,
              AppStrings.textoExplorarMundoPokemon,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.colorTextoSecundarioAuth(context),
              ),
            ),
            SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.registerPage);
              },
              child: Container(
                height: 68,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: AppColors.colorFondoBoton(context),
                ),
                child: Center(
                  child: Text(
                    AppStrings.textoCrearCuenta,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.loginPage);
              },
              child: Text(
                AppStrings.textoYaTengoUnaCuenta,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.colorFondoBoton(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

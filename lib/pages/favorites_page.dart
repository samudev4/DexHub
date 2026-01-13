import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/favorites_controller.dart';
import '../widgets/pokemon_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesController = context.watch<FavoritesController>();
    final favorites = favoritesController.favorites;

    if (favorites.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.colorFondoScaffold(context),
        appBar: AppBar(
          backgroundColor: AppColors.colorFondoAppBar(context),
          centerTitle: true,
          scrolledUnderElevation: 0,
          title: Text(
            AppStrings.textoFavoritos,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.colorTexto(context),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppStrings.rutaMagikarp, height: 280, width: 280),
              SizedBox(height: 16),
              Text(
                AppStrings.textoNoTienesNingunPokemonAnadido,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.colorTexto(context),
                ),
              ),
              SizedBox(height: 8),
              Text(
                AppStrings.textoHazClicEnElIconoDelCorazon,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.colorTexto(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.colorFondoScaffold(context),
      appBar: AppBar(
        backgroundColor: AppColors.colorFondoAppBar(context),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.textoFavoritos,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.colorTexto(context),
          ),
        ),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return PokemonCard(pokemon: favorites[index]);
        },
      ),
    );
  }
}

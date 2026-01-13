// ignore_for_file: deprecated_member_use

import 'package:dexhub/pages/region_pokedex_page.dart';
import 'package:dexhub/utils/region/region_card_gen_name.dart';
import 'package:dexhub/utils/region/region_card_starter_pokemons.dart';
import 'package:flutter/material.dart';
import 'package:dexhub/models/region_model.dart';
import 'package:dexhub/utils/region/region_card_background_image.dart';
import 'package:google_fonts/google_fonts.dart';

class RegionCard extends StatelessWidget {
  final RegionModel region;

  const RegionCard({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RegionPokedexPage(region: region)),
        );
      },

      child: Container(
        height: 140,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(
              RegionCardBackgroundImage.getRegionImage(region.name),
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Imagen de fondo
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(
                    RegionCardBackgroundImage.getRegionImage(region.name),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Gradient solo detrás del texto
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Contenido (texto y Pokémon) encima del gradient
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Columna de texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          capitalize(region.name),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          RegionCardGenName.getRegionGeneration(region.name),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pokémon iniciales
                  Row(
                    children:
                        RegionCardStarterPokemons.getStarterPokemons(
                              region.name,
                            )
                            .map(
                              (path) => Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Image.asset(path, width: 75, height: 75),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

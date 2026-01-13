import 'package:dexhub/controllers/favorites_controller.dart';
import 'package:dexhub/models/pokemon_model.dart';
import 'package:dexhub/pages/pokemon_details.dart';
import 'package:dexhub/utils/pokemon/pokemon_card_background_colors.dart';
import 'package:dexhub/utils/pokemon/pokemon_type_colors.dart';
import 'package:dexhub/utils/pokemon/pokemon_type_images.dart';
import 'package:dexhub/utils/pokemon/pokemon_type_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PokemonCard extends StatefulWidget {
  final PokemonModel pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;

    final mainType = pokemon.types.first;
    final backgroundColor = PokemonTypeColors.getColor(mainType);
    final backgroundCardColor = PokemonTypeBackgroundCardColor.getColor(
      mainType,
    );

    final favoritesController = context.watch<FavoritesController>();
    final isFavorite = favoritesController.isFavorite(pokemon.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PokemonDetailsPage(pokemonId: pokemon.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundCardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // LEFT SIDE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nº ${pokemon.id.toString().padLeft(3, '0')}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    capitalize(pokemon.name),
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: pokemon.types.map((type) {
                          final color = PokemonTypeColors.getColor(type);

                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      getTypeImage(type),
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  capitalize(typeEngToEsp(type)),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff000000),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT SIDE
            Stack(
              alignment: Alignment.topRight,
              children: [
                SizedBox(
                  width: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0.85,
                          child: Image.asset(
                            getTypeImageVector(pokemon.types.first),
                            width: 80,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Image.network(
                          pokemon.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ],
                    ),
                  ),
                ),

                // ❤️ FAVORITE BUTTON WITH POP ANIMATION
                GestureDetector(
                  onTap: () async {
                    await favoritesController.toggleFavorite(pokemon);

                    if (!isFavorite) {
                      _controller.forward().then((_) => _controller.reverse());
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (_, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 26,
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

  String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

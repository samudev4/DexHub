// ignore_for_file: deprecated_member_use

import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:dexhub/controllers/favorites_controller.dart';
import 'package:dexhub/models/pokemon_model.dart';
import 'package:dexhub/services/pokemon_service.dart';
import 'package:dexhub/utils/pokemon/pokemon_type_colors.dart';
import 'package:dexhub/utils/pokemon/pokemon_type_images.dart';
import 'package:dexhub/utils/pokemon/pokemon_type_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PokemonDetailsPage extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailsPage({super.key, required this.pokemonId});

  @override
  State<PokemonDetailsPage> createState() => _PokemonDetailsPageState();
}

class _PokemonDetailsPageState extends State<PokemonDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  PokemonModel? pokemon; // <- puede empezar en null
  final pokemonService = PokemonService();
  Map<String, double>? genderRates;
  List<String> weaknessesList = [];
  List<String> strongAgainstList = [];
  List<String> inmuneAgainstList = [];
  List<String> noDamageToList = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    fetchPokemon();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchPokemon() async {
    try {
      final response = await http.get(
        Uri.parse("https://pokeapi.co/api/v2/pokemon/${widget.pokemonId}"),
      );

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final basePokemon = PokemonModel.fromApi(data);

      final category = await pokemonService.getPokemonCategory(basePokemon.id);
      final description = await pokemonService.getPokemonDescription(
        basePokemon.id,
      );
      final gender = await pokemonService.getGenderRate(basePokemon.id);
      final weaknesses = await pokemonService.getWeaknesses(basePokemon.types);
      final strongAgainst = await pokemonService.getStrongAgainst(
        basePokemon.types,
      );
      final inmuneAgainst = await pokemonService.getInmuneAgainst(
        basePokemon.types,
      );
      final noDamageTo = await pokemonService.getInmuneTo(basePokemon.types);
      final evolutionChain = await pokemonService.getEvolutionChain(
        basePokemon.id,
      );

      setState(() {
        genderRates = gender; // 👈 AQUÍ SE ASIGNA
        pokemon = PokemonModel(
          id: basePokemon.id,
          name: basePokemon.name,
          imageUrl: basePokemon.imageUrl,
          types: basePokemon.types,
          height: basePokemon.height,
          weight: basePokemon.weight,
          ability: basePokemon.ability,
          category: category,
          description: description,
          evolutionChain: evolutionChain,
        );
        weaknessesList = weaknesses;
        strongAgainstList = strongAgainst;
        inmuneAgainstList = inmuneAgainst;
        noDamageToList = noDamageTo;
      });
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pokemon == null) {
      return Scaffold(
        backgroundColor: AppColors.colorFondoScaffold(context),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final favoritesController = context.watch<FavoritesController>();
    final isFavorite = favoritesController.isFavorite(pokemon!.id);
    final mainType = pokemon!.types.first;
    final backgroundColor = PokemonTypeColors.getColor(mainType);
    final desc = (pokemon!.description ?? AppStrings.textoSinDescripcion)
        .replaceAll("\n", " ")
        .replaceAll("\f", " ")
        .trim();

    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () async {
              await favoritesController.toggleFavorite(pokemon!);

              if (!isFavorite) {
                _controller.forward().then((_) => _controller.reverse());
              }
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(4),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite
                    ? Colors.red
                    : AppColors.colorFondoActions(context),
                size: 32,
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
        leading: Padding(
          padding: EdgeInsetsGeometry.only(left: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.colorFondoActions(context),
              size: 24,
            ),
          ),
        ),
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: AppColors.colorFondoScaffold(context),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER CURVO --- //
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(180),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          getTypeImageVector(mainType),
                          height: 250,
                        ),
                      ),
                      Center(
                        child: Image.network(pokemon!.imageUrl, height: 200),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // TIPOS
                ],
              ),
            ),
            SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalize(pokemon!.name),
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: AppColors.colorTexto(context),
                    ),
                  ),
                  Text(
                    "Nº ${pokemon!.id.toString().padLeft(3, '0')}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: AppColors.colorTexto(context),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        height: 36,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: pokemon!.types.map((type) {
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
                                      _capitalize(typeEngToEsp(type)),
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
                  SizedBox(height: 24),
                  Text(
                    desc,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.colorTexto(context),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(
                    color: Colors.grey.withOpacity(0.2),
                    thickness: 1,
                    height: 10,
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 12, // espacio horizontal
                    runSpacing: 12, // espacio vertical
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 52) / 2,
                        child: _buildInfoBox(
                          icon: Icons.monitor_weight_outlined,
                          label: AppStrings.textoPeso,
                          value: "${pokemon!.weight} kg",
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 52) / 2,
                        child: _buildInfoBox(
                          icon: Icons.height,
                          label: AppStrings.textoAltura,
                          value: "${pokemon!.height} m",
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 52) / 2,
                        child: _buildInfoBox(
                          icon: Icons.category_outlined,
                          label: AppStrings.textoCategoria,
                          value: pokemon!.category ?? "—",
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 52) / 2,
                        child: _buildInfoBox(
                          icon: Icons.auto_fix_high_outlined,
                          label: AppStrings.textoHabilidad,
                          value: pokemon!.ability ?? "—",
                        ),
                      ),
                    ],
                  ),
                  if (genderRates != null) ...[
                    const SizedBox(height: 30),

                    Center(
                      child: Text(
                        AppStrings.textoGenero,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFFFF7596),
                      ),
                      child: Row(
                        children: [
                          // Porción masculina
                          Expanded(
                            flex: genderRates!["male"]!.round(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff2551C3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          // Porción femenina
                          Expanded(
                            flex: genderRates!["female"]!.round(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFF7596),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "♂ ${genderRates!["male"]!.toStringAsFixed(1)}%",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: AppColors.colorTexto(context),
                          ),
                        ),
                        Text(
                          "♀ ${genderRates!["female"]!.toStringAsFixed(1)}%",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: AppColors.colorTexto(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 40),

                  Text(
                    AppStrings.textoMuyDebilContra,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.colorTexto(context),
                    ),
                  ),

                  SizedBox(height: 14),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: weaknessesList.map((weak) {
                      final color = PokemonTypeColors.getColor(
                        weak,
                      ); // como usas en tipos
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  getTypeImage(
                                    weak,
                                  ), // 🖼️ icono por tipo (como ya usas)
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _capitalize(
                                typeEngToEsp(weak),
                              ), // tu sistema actual
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 40),

                  Text(
                    AppStrings.textoMuyEficazContra,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.colorTexto(context),
                    ),
                  ),
                  SizedBox(height: 14),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: strongAgainstList.map((strong) {
                      final color = PokemonTypeColors.getColor(
                        strong,
                      ); // como usas en tipos
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  getTypeImage(
                                    strong,
                                  ), // 🖼️ icono por tipo (como ya usas)
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _capitalize(
                                typeEngToEsp(strong),
                              ), // tu sistema actual
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  if (inmuneAgainstList.isNotEmpty) ...[
                    SizedBox(height: 40),

                    Text(
                      AppStrings.textoEsInmuneA,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorTexto(context),
                      ),
                    ),
                    SizedBox(height: 14),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: inmuneAgainstList.map((inmuneAgainst) {
                        final color = PokemonTypeColors.getColor(
                          inmuneAgainst,
                        ); // como usas en tipos
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    getTypeImage(
                                      inmuneAgainst,
                                    ), // 🖼️ icono por tipo (como ya usas)
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _capitalize(
                                  typeEngToEsp(inmuneAgainst),
                                ), // tu sistema actual
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (noDamageToList.isNotEmpty) ...[
                    SizedBox(height: 40),

                    Text(
                      AppStrings.textoNoHaceDanoA,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorTexto(context),
                      ),
                    ),
                    SizedBox(height: 14),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: noDamageToList.map((noDamageTo) {
                        final color = PokemonTypeColors.getColor(
                          noDamageTo,
                        ); // como usas en tipos
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    getTypeImage(
                                      noDamageTo,
                                    ), // 🖼️ icono por tipo (como ya usas)
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _capitalize(
                                  typeEngToEsp(noDamageTo),
                                ), // tu sistema actual
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  // --- EVOLUCIONES --- //
                  if (pokemon!.evolutionChain != null &&
                      pokemon!.evolutionChain!.length > 1) ...[
                    const SizedBox(height: 40),

                    Text(
                      AppStrings.textoEvoluciones,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorTexto(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.colorFondoScaffold(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          for (
                            int i = 0;
                            i < pokemon!.evolutionChain!.length;
                            i++
                          ) ...[
                            _buildEvolutionRow(pokemon!.evolutionChain![i]),

                            if (i < pokemon!.evolutionChain!.length - 1) ...[
                              const SizedBox(height: 10),
                              Column(
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                  Text(
                                    "Nivel ${pokemon!.evolutionChain![i + 1]["min_level"] ?? "?"}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _buildEvolutionRow(Map<String, dynamic> evo) {
    return FutureBuilder(
      future: http.get(
        Uri.parse("https://pokeapi.co/api/v2/pokemon/${evo["name"]}"),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final data = json.decode(snapshot.data!.body);

        final id = data["id"];
        final image =
            data["sprites"]["other"]["official-artwork"]["front_default"];
        final name = data["name"];
        final types = (data["types"] as List)
            .map((t) => t["type"]["name"] as String)
            .toList();

        final mainType = types.first;
        final color = PokemonTypeColors.getColor(mainType);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PokemonDetailsPage(pokemonId: id),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.colorFondoScaffold(context),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                width: 0.8,
                color: AppColors.colorTexto(
                  context,
                ).withOpacity(0.07), // 🌫️ borde sutil y elegante
              ),
            ),

            child: Row(
              children: [
                // Imagen
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color,
                  backgroundImage: NetworkImage(image),
                ),

                const SizedBox(width: 12),

                // Nombre + Número + Tipos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(name),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      Text(
                        "Nº ${id.toString().padLeft(3, '0')}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      const SizedBox(height: 6),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: types.map((t) {
                            final typeColor = PokemonTypeColors.getColor(t);
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor,
                                borderRadius: BorderRadius.circular(50),
                              ),

                              child: Row(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        getTypeImage(t),
                                        width: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    typeEngToEsp(t),
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF000000),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.colorTexto(context).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.colorTexto(context),
            ),
          ),
        ],
      ),
    );
  }
}

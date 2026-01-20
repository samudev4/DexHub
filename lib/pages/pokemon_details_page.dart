// ignore_for_file: deprecated_member_use

import 'dart:convert';

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
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

void logMoves(String msg) {
  debugPrint("🟣 [MOVES] $msg");
}

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


  // ✅ Lazy load de movimientos
  final int _batchSize = 20;

  final Map<String, int> _loadedCount = {
    "level-up": 20,
    "machine": 0,
    "tutor": 0,
    "egg": 0,
  };

  bool _loadingMoreLevel = false;
  bool _loadingMoreMachine = false;
  bool _loadingMoreTutor = false;
  bool _loadingMoreEgg = false;

  final List<String> _methodOrder = ["level-up", "machine", "tutor", "egg"];
  int _currentMethodIndex = 0; // 🔥 método que se está mostrando ahora

  // Movimientos cargados (con descripción + nombre ES desde servicio)
  Map<String, List<PokemonMove>> movesByMethod = {};
  bool loadingMoves = false;

  // ✅ para que solo se dispare 1 vez la carga inicial de movimientos
  bool _movesRequested = false;
  Map<String, dynamic>? _pokemonJson; // ✅ guardamos el json base

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

  Future<void> _loadMovesOnDemand() async {
    if (_pokemonJson == null) return;
    if (_movesRequested) return;

    _movesRequested = true;

    final rawMoves = (_pokemonJson?["moves"] as List?) ?? [];

    // ✅ 1) Pintar rápido sin internet
    final fast = pokemonService.parseMovesFast(rawMoves);

    setState(() {
      movesByMethod = fast;
      loadingMoves = false; // OJO aquí: quitamos el loader rápido
    });

    // ✅ 2) Enriquecer en background (sin bloquear UI)
    pokemonService.enrichMovesWithSpanishAndDesc(fast).then((enriched) {
      if (!mounted) return;
      setState(() {
        movesByMethod = enriched;
      });
    });
  }

  void _loadNextBatch() {
    if (movesByMethod.isEmpty) {
      logMoves("❌ movesByMethod vacío, no hago nada");
      return;
    }

    final currentMethod = _methodOrder[_currentMethodIndex];
    final total = (movesByMethod[currentMethod] ?? []).length;
    final loaded = _loadedCount[currentMethod] ?? 0;

    logMoves(
      "📌 Método actual=$currentMethod | cargados=$loaded / total=$total",
    );

    if (loaded < total) {
      final newCount = (loaded + _batchSize).clamp(0, total);
      logMoves("➕ CARGO MÁS del método $currentMethod → $newCount");

      setState(() {
        _loadedCount[currentMethod] = newCount;
      });
      return;
    }

    logMoves("✅ Método $currentMethod COMPLETO");

    if (_currentMethodIndex < _methodOrder.length - 1) {
      setState(() {
        do {
          _currentMethodIndex++;
          final nextMethod = _methodOrder[_currentMethodIndex];
          _loadedCount[nextMethod] = _batchSize;

          logMoves(
            "➡️ Cambio a método=$nextMethod (index=$_currentMethodIndex)",
          );
        } while (_currentMethodIndex < _methodOrder.length - 1 &&
            (movesByMethod[_methodOrder[_currentMethodIndex]] ?? []).isEmpty);
      });
    } else {
      logMoves("🏁 TODOS LOS MÉTODOS COMPLETADOS");
    }
  }

  Future<void> fetchPokemon() async {
    try {
      final response = await http.get(
        Uri.parse("https://pokeapi.co/api/v2/pokemon/${widget.pokemonId}"),
      );

      if (response.statusCode != 200) return;

      final Map<String, dynamic> data = Map<String, dynamic>.from(
        jsonDecode(response.body),
      );

      _pokemonJson = data;

      _pokemonJson = data;

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

      if (!mounted) return;

      setState(() {
        genderRates = gender;
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
        body: const Center(child: CircularProgressIndicator()),
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
          const SizedBox(width: 16),
        ],
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
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
        physics: const ClampingScrollPhysics(),
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
                ],
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

                  const SizedBox(height: 24),

                  // TIPOS
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

                  const SizedBox(height: 24),

                  Text(
                    desc,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.colorTexto(context),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Divider(
                    color: Colors.grey.withOpacity(0.2),
                    thickness: 1,
                    height: 10,
                  ),

                  const SizedBox(height: 16),

                  // INFO BOXES
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
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

                  // GÉNERO
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
                        color: const Color(0xFFFF7596),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: genderRates!["male"]!.round(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff2551C3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: genderRates!["female"]!.round(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF7596),
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

                  const SizedBox(height: 40),

                  // DEBILIDADES
                  Text(
                    AppStrings.textoMuyDebilContra,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.colorTexto(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: weaknessesList.map((weak) {
                      final color = PokemonTypeColors.getColor(weak);
                      return _typeChip(context, weak, color);
                    }).toList(),
                  ),

                  const SizedBox(height: 40),

                  // FUERTE
                  Text(
                    AppStrings.textoMuyEficazContra,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.colorTexto(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: strongAgainstList.map((strong) {
                      final color = PokemonTypeColors.getColor(strong);
                      return _typeChip(context, strong, color);
                    }).toList(),
                  ),

                  if (inmuneAgainstList.isNotEmpty) ...[
                    const SizedBox(height: 40),
                    Text(
                      AppStrings.textoEsInmuneA,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorTexto(context),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: inmuneAgainstList.map((t) {
                        final color = PokemonTypeColors.getColor(t);
                        return _typeChip(context, t, color);
                      }).toList(),
                    ),
                  ],

                  if (noDamageToList.isNotEmpty) ...[
                    const SizedBox(height: 40),
                    Text(
                      AppStrings.textoNoHaceDanoA,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorTexto(context),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: noDamageToList.map((t) {
                        final color = PokemonTypeColors.getColor(t);
                        return _typeChip(context, t, color);
                      }).toList(),
                    ),
                  ],

                  // EVOLUCIONES
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
                                  const Icon(
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

                  const SizedBox(height: 40),

                  // MOVIMIENTOS (lazy load + paginado)
                  VisibilityDetector(
                    key: const Key("moves-section"),
                    onVisibilityChanged: (info) {
                      if (info.visibleFraction > 0.2) {
                        _loadMovesOnDemand();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Movimientos",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.colorTexto(context),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (movesByMethod.isEmpty && loadingMoves)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Cargando movimientos...",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (!loadingMoves && movesByMethod.isNotEmpty) ...[
                          for (int i = 0; i <= _currentMethodIndex; i++) ...[
                            _buildMovesSection(
                              context,
                              _methodTitle(_methodOrder[i]),
                              _methodOrder[i],
                            ),
                          ],
                        ],

                        if (!loadingMoves && movesByMethod.isNotEmpty)
                          VisibilityDetector(
                            key: Key(
                              "moves-load-more-${_currentMethodIndex}-${DateTime.now().millisecondsSinceEpoch}",
                            ),
                            onVisibilityChanged: (info) {
                              logMoves(
                                "Detector GLOBAL visibleFraction=${info.visibleFraction.toStringAsFixed(2)}",
                              );

                              if (info.visibleFraction > 0.2) {
                                logMoves("✅ DISPARA _loadNextBatch()");
                                _loadNextBatch();
                              }
                            },
                            child: Container(
                              height: 80,
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: const Text(""),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _typeChip(BuildContext context, String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(getTypeImage(type), width: 16, height: 16),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _capitalize(typeEngToEsp(type)),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionRow(Map<String, dynamic> evo) {
    return FutureBuilder(
      future: http.get(
        Uri.parse("https://pokeapi.co/api/v2/pokemon/${evo["name"]}"),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
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
                color: AppColors.colorTexto(context).withOpacity(0.07),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color,
                  backgroundImage: NetworkImage(image),
                ),
                const SizedBox(width: 12),
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
                                    decoration: const BoxDecoration(
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
                                      color: const Color(0xFF000000),
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

  Widget _buildMovesSection(
    BuildContext context,
    String title,
    String methodKey,
  ) {
    final allMoves = movesByMethod[methodKey] ?? [];
    final loadedCount = _loadedCount[methodKey] ?? 0;
    final visibleMoves = allMoves.take(loadedCount).toList();

    if (visibleMoves.isEmpty) return const SizedBox.shrink();

    final bool canLoadMore = loadedCount < allMoves.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorFondoScaffold(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.colorTexto(context),
            ),
          ),
          const SizedBox(height: 12),

          ...visibleMoves.map((m) {
            // ✅ Nombre en ES si existe (lo devuelve el service)
            final moveTitle =
    (m.nameEs != null ? m.nameEs! : "Cargando...").replaceAll("-", " ");


            final levelText = (methodKey == "level-up")
                ? ((m.level == 0) ? "Inicial" : "Nivel ${m.level}")
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (levelText != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            levelText,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],

                      Expanded(
                        child: Text(
                          _capitalize(moveTitle),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.colorTexto(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (m.description != null &&
                      m.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      m.description!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: AppColors.colorTexto(context),
                      ),
                    ),
                  ],

                  Divider(
                    height: 18,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.12),
                  ),
                ],
              ),
            );
          }),

          // ✅ Lazy load por scroll
          if (canLoadMore)
            VisibilityDetector(
              key: Key("loadmore-$methodKey-$loadedCount"),
              onVisibilityChanged: (info) async {
                if (info.visibleFraction <= 0.2) return;

                // ✅ solo dejar cargar el método actual (para que no se pisen)
                final currentMethod = _methodOrder[_currentMethodIndex];
                if (methodKey != currentMethod) return;

                // antispam
                if (methodKey == "level-up" && _loadingMoreLevel) return;
                if (methodKey == "machine" && _loadingMoreMachine) return;
                if (methodKey == "tutor" && _loadingMoreTutor) return;
                if (methodKey == "egg" && _loadingMoreEgg) return;

                setState(() {
                  if (methodKey == "level-up") _loadingMoreLevel = true;
                  if (methodKey == "machine") _loadingMoreMachine = true;
                  if (methodKey == "tutor") _loadingMoreTutor = true;
                  if (methodKey == "egg") _loadingMoreEgg = true;
                });

                // ✅ cargar siguiente batch
                _loadNextBatch();

                // ✅ reset loading después
                if (!mounted) return;
                setState(() {
                  if (methodKey == "level-up") _loadingMoreLevel = false;
                  if (methodKey == "machine") _loadingMoreMachine = false;
                  if (methodKey == "tutor") _loadingMoreTutor = false;
                  if (methodKey == "egg") _loadingMoreEgg = false;
                });
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  String _methodTitle(String key) {
    switch (key) {
      case "level-up":
        return "Por nivel";
      case "machine":
        return "MT / MO";
      case "tutor":
        return "Tutor";
      case "egg":
        return "Huevo";
      default:
        return key;
    }
  }
}

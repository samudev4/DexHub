import 'dart:convert';

import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/models/pokemon_model.dart';
import 'package:dexhub/models/region_model.dart';
import 'package:dexhub/services/pokemon_service.dart';
import 'package:dexhub/widgets/pokemon_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class RegionPokedexPage extends StatefulWidget {
  final RegionModel region;

  const RegionPokedexPage({super.key, required this.region});

  @override
  State<RegionPokedexPage> createState() => _RegionPokedexPageState();
}

class _RegionPokedexPageState extends State<RegionPokedexPage> {
  final PokemonService _service = PokemonService();
  final ScrollController _scrollController = ScrollController();

  bool _showScrollToTop = false;

  // 🔢 entries crudas de la región
  final List<dynamic> _entries = [];

  // 🧬 pokémon ya cargados
  final List<PokemonModel> _pokemons = [];

  int _offset = 0;
  final int _limit = 20;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // 📥 CARGA INICIAL (solo entries + primeros 20)
  // ─────────────────────────────────────────────
  Future<void> _loadInitial() async {
    debugPrint("🌍 [UI] Cargando región ${widget.region.name}");

    final entries = await _service.getRegionEntries(widget.region.name);

    if (!mounted) return;

    _entries.addAll(entries);

    await _loadMore();

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  // ─────────────────────────────────────────────
  // ➕ CARGAR MÁS (20 EN 20)
  // ─────────────────────────────────────────────
  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;

    _loadingMore = true;
    if (mounted) setState(() {});

    final end = (_offset + _limit).clamp(0, _entries.length);
    final slice = _entries.sublist(_offset, end);

    for (final entry in slice) {
      final speciesUrl = entry['pokemon_species']['url'];

      // 🔑 extracción segura del ID
      final parts = speciesUrl.split('/');
      final id = parts[parts.length - 2];

      final resp = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'),
      );

      if (resp.statusCode == 200) {
        _pokemons.add(PokemonModel.fromApi(json.decode(resp.body)));
      }
    }

    _offset = end;
    _hasMore = _offset < _entries.length;

    _loadingMore = false;
    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────
  // 📜 SCROLL INFINITO + BOTÓN SUBIR
  // ─────────────────────────────────────────────
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;

    // 🔼 Mostrar / ocultar botón
    final shouldShow = position > 300;
    if (shouldShow != _showScrollToTop && mounted) {
      setState(() => _showScrollToTop = shouldShow);
    }

    // 🔽 Scroll infinito
    if (position >= max - 200 && !_loadingMore && _hasMore) {
      _loadMore();
    }
  }

  void _scrollToTop() => _scrollController.animateTo(
    0,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOut,
  );

  // ─────────────────────────────────────────────
  // 🎨 UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondoScaffold(context),
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsetsGeometry.only(left: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.colorTexto(context),
              size: 24,
            ),
          ),
        ),
        centerTitle: true,
        //automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.colorFondoAppBar(context),
        title: Text(
          _capitalize(widget.region.name),
          style: GoogleFonts.poppins(
            color: AppColors.colorTextoPantallasPrincipales(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: true,
            top: false,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _pokemons.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _pokemons.length) {
                        return PokemonCard(pokemon: _pokemons[index]);
                      }

                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
          ),

          // ✅ AQUÍ ESTABA EL FALLO: faltaba pintar el botón
          if (_showScrollToTop) _scrollTopButton(context),
        ],
      ),
    );
  }

  Widget _scrollTopButton(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomSafe + 40, // 👈 MÁS ARRIBA (ajustable)
      left: MediaQuery.of(context).size.width / 2 - 28,
      child: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: AppColors.colorFondoScaffold(context),
        shape: const CircleBorder(),
        child: Icon(
          Icons.keyboard_arrow_up,
          color: AppColors.colorTexto(context),
        ),
      ),
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

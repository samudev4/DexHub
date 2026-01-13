import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:dexhub/theme/theme_provider.dart';
import 'package:dexhub/utils/pokemon/pokemon_type_colors.dart';
import 'package:dexhub/utils/pokemon/pokemon_type_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';
import '../models/pokemon_model.dart';

class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});

  @override
  State<PokedexPage> createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  final PokemonService _pokemonService = PokemonService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// 📌 Lista general (paginada desde API)
  final List<PokemonModel> _allPokemons = [];
  int _offset = 0;
  final int _limit = 20;

  int _typeOffset = 0;
  bool _isTypeLoading = false;

  /// 📌 Lo que se muestra
  List<PokemonModel> _filteredPokemons = [];

  String _selectedType = AppStrings.textoTodosLosTipos;
  String _sortOrder = AppStrings.textoMenorNumero;

  bool _isLoading = false;
  bool _hasMore = true;
  bool _showScrollToTop = false;
  int _searchRequestId = 0;

  /// Lista de tipos posibles
  final List<String> _types = [
    AppStrings.textoTodosLosTipos,
    AppStrings.textoNormal,
    AppStrings.textoFire,
    AppStrings.textoWater,
    AppStrings.textoElectric,
    AppStrings.textoGrass,
    AppStrings.textoIce,
    AppStrings.textoFighting,
    AppStrings.textoPoison,
    AppStrings.textoGround,
    AppStrings.textoFlying,
    AppStrings.textoPsychic,
    AppStrings.textoBug,
    AppStrings.textoRock,
    AppStrings.textoGhost,
    AppStrings.textoDragon,
    AppStrings.textoDark,
    AppStrings.textoSteel,
    AppStrings.textoFairy,
  ];

  @override
  void initState() {
    super.initState();
    _loadPokemons();
    _scrollController.addListener(_onScroll);
  }

  // 🚀 Cargar más Pokémon generales
  Future<void> _loadPokemons() async {
    if (_isLoading ||
        !_hasMore ||
        _selectedType != AppStrings.textoTodosLosTipos) {
      return;
    }

    setState(() => _isLoading = true); // 👈 CLAVE

    final newData = await _pokemonService.getPokemons(
      limit: _limit,
      offset: _offset,
    );

    if (newData.isEmpty) {
      _hasMore = false;
      setState(() => _isLoading = false);
      return;
    }

    _offset += _limit;
    _allPokemons.addAll(newData);

    setState(() => _isLoading = false);

    if (_searchController.text.isEmpty) {
      _applyFilters();
    }
  }

  Future<void> _loadMoreByType() async {
    if (_isTypeLoading || !_hasMore) return;

    _isTypeLoading = true;
    setState(() {}); // para mostrar spinner

    final newData = await _pokemonService.getPokemonsByTypePaginated(
      type: _selectedType,
      offset: _typeOffset,
      limit: _limit,
    );

    if (newData.isEmpty) {
      _hasMore = false;
      _isTypeLoading = false;
      setState(() {});
      return;
    }

    _typeOffset += _limit;
    _filteredPokemons.addAll(newData);

    // Orden visual
    _sort(_filteredPokemons);

    _isTypeLoading = false;
    setState(() {});
  }

  // 🧠 Aplicar búsqueda o filtro por tipo
  Future<void> _applyFilters() async {
    final query = _searchController.text.trim().toLowerCase();

    // 🔍 BÚSQUEDA POR NOMBRE (prioridad absoluta)
    if (query.isNotEmpty) {
      _hasMore = false;

      // 🔐 generar id único para esta búsqueda
      final int requestId = ++_searchRequestId;

      final results = await _pokemonService.searchPokemonsByName(query);

      // ⛔ si llegó una búsqueda más nueva, ignorar esta
      if (!mounted || requestId != _searchRequestId) return;

      List<PokemonModel> filtered = results;

      if (_selectedType != AppStrings.textoTodosLosTipos) {
        filtered = filtered
            .where((p) => p.types.contains(_selectedType.toLowerCase()))
            .toList();
      }

      _sort(filtered);

      setState(() {
        _filteredPokemons = filtered;
      });

      return;
    }

    // 🎯 FILTRO POR TIPO (sin búsqueda)
    _searchRequestId++; // ⛔ invalida búsquedas anteriores

    if (_selectedType != AppStrings.textoTodosLosTipos) {
      _filteredPokemons.clear();
      _typeOffset = 0;
      _hasMore = true;

      await _loadMoreByType();
      return;
    }

    // 📌 LISTA GENERAL
    final base = [..._allPokemons];

    _sort(base);

    setState(() {
      _filteredPokemons = base;
      _hasMore = _allPokemons.length % _limit == 0;
    });
  }

  // 🔄 Ordenación
  void _sort(List<PokemonModel> list) {
    list.sort(
      (a, b) => _sortOrder == AppStrings.textoMenorNumero
          ? a.id.compareTo(b.id)
          : b.id.compareTo(a.id),
    );
  }

  // 📌 Scroll infinito
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;
    final isDescending = _sortOrder == AppStrings.textoMayorNumero;

    // 🔼 Botón subir (solo modo normal)
    if (!isDescending) {
      final shouldShow = position > 300;
      if (shouldShow != _showScrollToTop) {
        setState(() => _showScrollToTop = shouldShow);
      }
    }

    if (!_hasMore || _searchController.text.isNotEmpty) return;

    final isGeneral = _selectedType == AppStrings.textoTodosLosTipos;

    if (!isDescending) {
      // ⬇️ MENOR NÚMERO → cargar al bajar
      if (position >= max - 200) {
        if (isGeneral && !_isLoading) {
          _loadPokemons();
        } else if (!isGeneral && !_isTypeLoading) {
          _loadMoreByType();
        }
      }
    } else {
      // ⬆️ MAYOR NÚMERO → cargar al subir
      if (position <= 200) {
        if (isGeneral && !_isLoading) {
          _loadPokemons();
        } else if (!isGeneral && !_isTypeLoading) {
          _loadMoreByType();
        }
      }
    }
  }

  // 🔼 Ir arriba
  void _scrollToTop() => _scrollController.animateTo(
    0,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 🌍 UI -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondoScaffold(context),
      body: Stack(
        children: [
          (_allPokemons.isEmpty && _filteredPokemons.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [_buildAppBar(), _buildList()],
                ),

          if (_showScrollToTop) _scrollTopButton(context),
        ],
      ),
    );
  }

  // 🔻 Widgets Reutilizables ----------------------------------------------------

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      scrolledUnderElevation: 0,
      floating: true,
      backgroundColor: AppColors.colorFondoAppBar(context),
      centerTitle: true,
      title: Text(
        AppStrings.textoNombreApp,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppColors.colorTextoPantallasPrincipales(context),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Column(children: [_buildSearchBar(), _buildFilters()]),
      ),
    );
  }

  Widget _buildList() {
    final isSearching = _searchController.text.isNotEmpty;
    final isDescending = _sortOrder == AppStrings.textoMayorNumero;
    final isLoadingMore = _hasMore && (_isLoading || _isTypeLoading);

    // 🔍 Búsqueda sin resultados
    if (isSearching && _filteredPokemons.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _NoResultsMessage(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // 🔍 Búsqueda con resultados
          if (isSearching) {
            return PokemonCard(pokemon: _filteredPokemons[index]);
          }

          // 🔼 SPINNER ARRIBA (Mayor número)
          if (isDescending && isLoadingMore && index == 0) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // 📦 Ajustar índice real cuando hay spinner arriba
          final dataIndex = (isDescending && isLoadingMore) ? index - 1 : index;

          if (dataIndex >= 0 && dataIndex < _filteredPokemons.length) {
            return PokemonCard(pokemon: _filteredPokemons[dataIndex]);
          }

          // 🔽 SPINNER ABAJO (Menor número)
          if (!isDescending && isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return const SizedBox.shrink();
        },
        childCount: isSearching
            ? _filteredPokemons.length
            : _filteredPokemons.length + (isLoadingMore ? 1 : 0),
      ),
    );
  }

  Widget _scrollTopButton(BuildContext context) {
    return Positioned(
      bottom: 20,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {}); // ✅ refresca para mostrar/ocultar la cruz
          _applyFilters();
        },
        decoration: InputDecoration(
          hintText: AppStrings.textoBuscarPokemon,
          prefixIcon: const Icon(Icons.search),

          // ✅ iOS clear button más pequeño (sin cerrar teclado)
          suffixIcon: _searchController.text.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _applyFilters();
                      setState(() {});
                    },
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.close, size: 22, color: Colors.white),
                      ),
                    ),
                  ),
                )
              : null,

          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterButton(
            label: _selectedType == AppStrings.textoTodosLosTipos
                ? _selectedType
                : typeEngToEsp(_selectedType),

            icon: Icons.category,
            color: _selectedType == AppStrings.textoTodosLosTipos
                ? Color(0xFF333333)
                : PokemonTypeColors.getColor(_selectedType),
            onTap: () => _openBottomSheet(
              title: AppStrings.textoFiltrarPorTipo,
              items: _types,
              selectedItem: _selectedType,
              onSelected: (v) {
                setState(() {
                  _selectedType = v;
                });
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 12),
          _filterButton(
            label: _sortOrder,
            icon: Icons.sort,
            color: Color(0xFF333333),
            onTap: () => _openBottomSheet(
              title: AppStrings.textoOrdenarPorNumero,
              items: [AppStrings.textoMenorNumero, AppStrings.textoMayorNumero],
              selectedItem: _sortOrder,
              onSelected: (v) {
                setState(() => _sortOrder = v);
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Icon(
                Icons.arrow_drop_down_outlined,
                size: 24,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBottomSheet({
    required List<String> items,
    required String selectedItem,
    required Function(String) onSelected,
    required String title,
  }) {
    final bool isDark = context.read<ThemeProvider>().isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: 500,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: items.map((item) {
                    final active = item == selectedItem;
                    final bg = title == AppStrings.textoFiltrarPorTipo
                        ? (item == AppStrings.textoTodosLosTipos
                              ? const Color(0xFF333333)
                              : PokemonTypeColors.getColor(item))
                        : const Color(0xFF333333);

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(item);
                      },
                      child: Container(
                        height: 52,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title == AppStrings.textoFiltrarPorTipo
                                  ? (item == AppStrings.textoTodosLosTipos
                                        ? item
                                        : typeEngToEsp(item))
                                  : item,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (active)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //static String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

class _NoResultsMessage extends StatelessWidget {
  const _NoResultsMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppStrings.textoNoSeEncontroNingunPokemon,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

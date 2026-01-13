import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/favorites_service.dart';

class FavoritesController with ChangeNotifier {
  final FavoritesService _service = FavoritesService();

  List<PokemonModel> _favorites = [];
  StreamSubscription? _subscription;

  List<PokemonModel> get favorites => _favorites;

  bool isFavorite(int pokemonId) {
    return _favorites.any((p) => p.id == pokemonId);
  }

  void startListening() {
    _subscription?.cancel();
    _subscription = _service.favoritesStream().listen((data) {
      _favorites = data;
      notifyListeners();
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _favorites = [];
  }

  Future<void> toggleFavorite(PokemonModel pokemon) async {
    if (isFavorite(pokemon.id)) {
      await _service.removeFavorite(pokemon.id);
    } else {
      await _service.addFavorite(pokemon);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

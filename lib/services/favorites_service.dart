import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pokemon_model.dart';

class FavoritesService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _favoritesRef =>
      _firestore.collection('users').doc(_uid).collection('favorites');

  Future<void> addFavorite(PokemonModel pokemon) async {
    if (_uid == null) return;

    await _favoritesRef.doc(pokemon.id.toString()).set({
      'id': pokemon.id,
      'name': pokemon.name,
      'imageUrl': pokemon.imageUrl,
      'types': pokemon.types,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(int pokemonId) async {
    if (_uid == null) return;

    await _favoritesRef.doc(pokemonId.toString()).delete();
  }

  Stream<List<PokemonModel>> favoritesStream() {
    if (_uid == null) return const Stream.empty();

    return _favoritesRef
        .orderBy('id', descending: false) // 🔑 ordenar por id ascendente
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return PokemonModel(
              id: data['id'],
              name: data['name'],
              imageUrl: data['imageUrl'],
              types: List<String>.from(data['types']),
            );
          }).toList(),
        );
  }
}

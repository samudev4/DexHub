// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dexhub/utils/region/region_to_pokedex.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  final Map<String, List> _typeCache = {};

  /// 📌 Obtener Pokémon con paginación desde PokeAPI
  Future<List<PokemonModel>> getPokemons({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cargar Pokémon');
      }

      final data = json.decode(response.body);
      final List results = data['results'];

      // Cargar detalles de cada Pokémon
      final pokemons = await Future.wait(
        results.map((p) async {
          final detailResponse = await http.get(Uri.parse(p['url']));
          if (detailResponse.statusCode != 200) {
            throw Exception('Error al cargar detalles de Pokémon');
          }
          return PokemonModel.fromApi(json.decode(detailResponse.body));
        }),
      );

      return pokemons;
    } catch (e) {
      print("⚠️ Error en getPokemons: $e");
      return [];
    }
  }

  /// 🔍 Buscar Pokémon por nombre exacto
  Future<List<PokemonModel>> searchPokemonsByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon/${name.toLowerCase()}'),
      );

      if (response.statusCode == 200) {
        return [PokemonModel.fromApi(json.decode(response.body))];
      }

      return []; // No encontrado
    } catch (e) {
      print("⚠️ Error buscando Pokémon: $e");
      return [];
    }
  }

  Future<List<PokemonModel>> getPokemonsByTypePaginated({
    required String type,
    required int offset,
    int limit = 20,
  }) async {
    if (!_typeCache.containsKey(type)) {
      final response = await http.get(
        Uri.parse('$baseUrl/type/${type.toLowerCase()}'),
      );

      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      _typeCache[type] = data['pokemon'];
    }

    final pokes = _typeCache[type]!;
    final end = (offset + limit).clamp(0, pokes.length);
    final slice = pokes.sublist(offset, end);

    final List<PokemonModel> result = [];

    for (final p in slice) {
      final url = p['pokemon']['url'];
      final detailResp = await http.get(Uri.parse(url));

      if (detailResp.statusCode == 200) {
        result.add(PokemonModel.fromApi(json.decode(detailResp.body)));
      }
    }

    return result;
  }

  Future<String?> getPokemonCategory(int id) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id'),
    );

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    final genera = data['genera'] as List;

    final esCategoryList = genera
        .where((g) => g['language']['name'] == 'es')
        .toList();

    if (esCategoryList.isEmpty) return null;
    return esCategoryList.first['genus'];
  }

  Future<String?> getPokemonDescription(int id) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id'),
    );

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    final description = data['flavor_text_entries'] as List;

    final esDescriptionList = description
        .where((g) => g['language']['name'] == 'es')
        .toList();

    if (esDescriptionList.isEmpty) return null;
    return esDescriptionList.first['flavor_text'];
  }

  Future<Map<String, double>?> getGenderRate(int id) async {
    final response = await http.get(
      Uri.parse("https://pokeapi.co/api/v2/pokemon-species/$id"),
    );

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final rate = data["gender_rate"];

    if (rate == -1) {
      return {"male": 0, "female": 0}; // Sin género
    }

    final female = (rate / 8) * 100;
    final male = 100 - female;

    return {"male": male.toDouble(), "female": female.toDouble()};
  }

  Future<List<String>> getWeaknesses(List<String> types) async {
    final Set<String> weaknesses = {};

    for (final type in types) {
      final englishType = type
          .toLowerCase(); // 👈 asegúrate de que es ENGLISH aquí

      final response = await http.get(Uri.parse("$baseUrl/type/$englishType"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final damageFrom = data["damage_relations"]["double_damage_from"];

        for (var item in damageFrom) {
          weaknesses.add(item["name"]);
        }
      }
    }

    return weaknesses.toList();
  }

  Future<List<String>> getStrongAgainst(List<String> types) async {
    final Set<String> strongAgainst = {};

    for (final type in types) {
      final englishType = type
          .toLowerCase(); // 👈 asegúrate de que es ENGLISH aquí

      final response = await http.get(Uri.parse("$baseUrl/type/$englishType"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final damageTo = data["damage_relations"]["double_damage_to"];

        for (var item in damageTo) {
          strongAgainst.add(item["name"]);
        }
      }
    }

    return strongAgainst.toList();
  }

  Future<List<String>> getInmuneAgainst(List<String> types) async {
    final Set<String> inmuneAgainst = {}; // set para evitar duplicados

    for (final type in types) {
      final englishType = type.toLowerCase();
      final response = await http.get(Uri.parse("$baseUrl/type/$englishType"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final noDamageFrom = data["damage_relations"]["no_damage_from"] as List;

        for (final item in noDamageFrom) {
          inmuneAgainst.add(item["name"] as String); // 💯 valor correcto
        }
      }
    }

    // elimina tipo propio si aparece
    return inmuneAgainst.where((e) => !types.contains(e)).toList();
  }

  Future<List<String>> getInmuneTo(List<String> types) async {
    final Set<String> inmuneTo = {}; // SET para evitar duplicados

    for (final type in types) {
      final englishType = type.toLowerCase();

      final response = await http.get(Uri.parse("$baseUrl/type/$englishType"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final noDamageTo = data["damage_relations"]["no_damage_to"] as List;

        for (var item in noDamageTo) {
          inmuneTo.add(item["name"] as String); // Añade al SET principal
        }
      }
    }

    // Elimina inmunidades hacia su propio tipo (si se da el caso)
    return inmuneTo.where((t) => !types.contains(t)).toList();
  }

  Future<List<Map<String, dynamic>>> getEvolutionChain(int pokemonId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/pokemon-species/$pokemonId"),
    );
    if (response.statusCode != 200) return [];

    final speciesData = json.decode(response.body);
    final evoUrl = speciesData["evolution_chain"]["url"];

    final evoResponse = await http.get(Uri.parse(evoUrl));
    final evoData = json.decode(evoResponse.body);

    List<Map<String, dynamic>> chain = [];

    void extract(chainNode) {
      final evoDetails = chainNode["evolution_details"].isNotEmpty
          ? chainNode["evolution_details"][0]
          : null;

      chain.add({
        "name": chainNode["species"]["name"],
        "min_level": evoDetails?["min_level"],

        // 👇 Detectar método
        "trigger": evoDetails?["trigger"]?["name"],
        "item": evoDetails?["item"]?["name"], // piedra
        "held_item": evoDetails?["held_item"]?["name"], // objeto equipado
        "time_of_day": evoDetails?["time_of_day"], // día/noche
        "location": evoDetails?["location"]?["name"], // localización
        "happiness": evoDetails?["min_happiness"], // amistad
        "trade_species": evoDetails?["trade_species"]?["name"], // intercambio
      });

      for (var next in chainNode["evolves_to"]) {
        extract(next);
      }
    }

    extract(evoData["chain"]);
    return chain;
  }

  Future<List<PokemonModel>> getPokemonsByRegion(String region) async {
    debugPrint("🌍 [REGION] Región solicitada: $region");

    final pokedex = regionToPokedex(region);
    debugPrint("📘 [REGION] Pokedex usada: $pokedex");

    final url = '$baseUrl/pokedex/$pokedex';
    debugPrint("🌐 [REGION] URL: $url");

    final response = await http.get(Uri.parse(url));
    debugPrint("📡 [REGION] Status code: ${response.statusCode}");

    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    final List entries = data['pokemon_entries'];

    debugPrint("🔢 [REGION] Total entries: ${entries.length}");

    final List<PokemonModel> result = [];

    for (int i = 0; i < entries.length; i++) {
      final speciesUrl = entries[i]['pokemon_species']['url'];

      // ✅ FIX DEFINITIVO AQUÍ
      final parts = speciesUrl.split('/');
      final id = parts[parts.length - 2];

      debugPrint("🆔 [REGION] ID extraído: $id");

      final pokeResp = await http.get(Uri.parse('$baseUrl/pokemon/$id'));

      if (pokeResp.statusCode == 200) {
        final pokemon = PokemonModel.fromApi(json.decode(pokeResp.body));
        debugPrint("✅ [POKEMON] ${pokemon.name}");
        result.add(pokemon);
      }
    }

    debugPrint("🎉 [REGION] TOTAL cargados: ${result.length}");
    return result;
  }

  Future<List<dynamic>> getRegionEntries(String region) async {
    final pokedex = regionToPokedex(region);

    final response = await http.get(Uri.parse('$baseUrl/pokedex/$pokedex'));

    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    return data['pokemon_entries'];
  }
}

class PokemonMove {
  final String name;
  final String? nameEs; // ✅ NUEVO
  final String method;
  final int? level;
  final String? description;
  

  PokemonMove({
    required this.name,
    this.nameEs, // ✅ NUEVO
    required this.method,
    this.level,
    this.description,
  });

  PokemonMove copyWith({
    String? name,
    String? nameEs,
    String? method,
    int? level,
    String? description,
    Map<String, List<PokemonMove>>? movesByMethod,

  }) {
    return PokemonMove(
      name: name ?? this.name,
      nameEs: nameEs ?? this.nameEs,
      method: method ?? this.method,
      level: level ?? this.level,
      description: description ?? this.description,
    );
  }
}

class PokemonModel {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final double? height;
  final double? weight;
  final String? ability;
  final String? category;
  final String? description;
  final Map<String, double>? genderRates;
  final List<Map<String, dynamic>>? evolutionChain;

  /// ✅ Movimientos agrupados por método
  /// keys típicas: "level-up", "machine", "tutor", "egg"
  final Map<String, List<PokemonMove>>? movesByMethod;

  PokemonModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    this.weight,
    this.height,
    this.ability,
    this.category,
    this.description,
    this.genderRates,
    this.evolutionChain,
    this.movesByMethod,
  });

  factory PokemonModel.fromApi(Map<String, dynamic> data) {
    return PokemonModel(
      id: data['id'],
      name: data['name'],
      imageUrl:
          data['sprites']['other']['official-artwork']['front_default'] ??
          data['sprites']['front_default'],
      types: (data['types'] as List)
          .map<String>((t) => t['type']['name'] as String)
          .toList(),
      weight: data['weight'] / 10,
      height: data['height'] / 10,
      ability: data['abilities'] != null && data['abilities'].isNotEmpty
          ? data['abilities'][0]['ability']['name']
          : null,

      // 👇 se completan después
      category: null,
      description: null,
      genderRates: null,
      evolutionChain: null,

      // 👇 se completa después en PokemonDetailsPage
      movesByMethod: null,
    );
  }

  PokemonModel copyWith({
    int? id,
    String? name,
    String? imageUrl,
    List<String>? types,
    double? height,
    double? weight,
    String? ability,
    String? category,
    String? description,
    Map<String, double>? genderRates,
    List<Map<String, dynamic>>? evolutionChain,
    Map<String, List<PokemonMove>>? movesByMethod,
  }) {
    return PokemonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      types: types ?? this.types,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      ability: ability ?? this.ability,
      category: category ?? this.category,
      description: description ?? this.description,
      genderRates: genderRates ?? this.genderRates,
      evolutionChain: evolutionChain ?? this.evolutionChain,
      movesByMethod: movesByMethod ?? this.movesByMethod,
    );
  }
}

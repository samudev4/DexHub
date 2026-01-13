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
      category: null,
      description: null,
      genderRates: null,
    );
  }
}

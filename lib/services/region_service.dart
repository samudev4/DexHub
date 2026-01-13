import 'dart:convert';

import 'package:dexhub/models/region_model.dart';
import 'package:http/http.dart' as http;

class RegionService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<RegionModel>> getRegions() async {
    final response = await http.get(Uri.parse('$baseUrl/region'));

    if (response.statusCode != 200) {
      throw Exception('Error al cargar Regiones');
    }

    final data = json.decode(response.body);
    final List results = data['results'];

    // Solo necesitamos el 'name' de cada región
    final regions = results.map((r) => RegionModel.fromApi(r)).toList();

    return regions;
  }
}

class RegionCardGenName {
  static const Map<String, String> generations = {
    'kanto': "1ª GEN.",
    'johto': "2ª GEN.",
    'hoenn': "3ª GEN.",
    'sinnoh': "4ª GEN.",
    'unova': "5ª GEN.",
    'kalos': "6ª GEN.",
    'alola': "7ª GEN.",
    'galar': "8ª GEN.",
    'paldea': "9ª GEN.",
  };

  static String getRegionGeneration(String region) {
    return generations[region.toLowerCase()] ?? "DESCONOCIDA";
  }
}

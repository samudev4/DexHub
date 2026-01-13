class RegionCardBackgroundImage {
  static const Map<String, String> images = {
    'kanto': "assets/images/regions/kanto.png",
    'johto': "assets/images/regions/johto.png",
    'hoenn': "assets/images/regions/hoenn.png",
    'sinnoh': "assets/images/regions/sinnoh.png",
    'unova': "assets/images/regions/unova.png",
    'kalos': "assets/images/regions/kalos.png",
    'alola': "assets/images/regions/alola.png",
    'galar': "assets/images/regions/galar.png",
  };

  static String getRegionImage(String region) {
    return images[region.toLowerCase()] ?? "assets/images/regions/kanto.png";
  }
}

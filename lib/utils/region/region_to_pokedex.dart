String regionToPokedex(String region) {
  switch (region.toLowerCase()) {
    case 'kanto':
      return 'kanto';
    case 'johto':
      return 'original-johto';
    case 'hoenn':
      return 'hoenn';
    case 'sinnoh':
      return 'original-sinnoh';
    case 'unova':
      return 'original-unova';
    case 'kalos':
      return 'kalos-central';
    case 'alola':
      return 'original-alola';
    case 'galar':
      return 'galar';
    default:
      throw Exception('Región no soportada');
  }
}

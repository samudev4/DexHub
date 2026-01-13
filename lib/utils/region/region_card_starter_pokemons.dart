class RegionCardStarterPokemons {
  static const Map<String, List<String>> starterPokemons = {
    'kanto': [
      "assets/images/regions/starter_pokemons/gen1/bulbasaur.png",
      "assets/images/regions/starter_pokemons/gen1/charmander.png",
      "assets/images/regions/starter_pokemons/gen1/squirtle.png",
    ],
    'johto': [
      "assets/images/regions/starter_pokemons/gen2/chikorita.png",
      "assets/images/regions/starter_pokemons/gen2/cyndaquil.png",
      "assets/images/regions/starter_pokemons/gen2/totodile.png",
    ],
    'hoenn': [
      "assets/images/regions/starter_pokemons/gen3/treecko.png",
      "assets/images/regions/starter_pokemons/gen3/torchic.png",
      "assets/images/regions/starter_pokemons/gen3/mudkip.png",
    ],
    'sinnoh': [
      "assets/images/regions/starter_pokemons/gen4/turtwig.png",
      "assets/images/regions/starter_pokemons/gen4/chimchar.png",
      "assets/images/regions/starter_pokemons/gen4/piplup.png",
    ],
    'unova': [
      "assets/images/regions/starter_pokemons/gen5/snivy.png",
      "assets/images/regions/starter_pokemons/gen5/tepig.png",
      "assets/images/regions/starter_pokemons/gen5/oshawott.png",
    ],
    'kalos': [
      "assets/images/regions/starter_pokemons/gen6/chespin.png",
      "assets/images/regions/starter_pokemons/gen6/fennekin.png",
      "assets/images/regions/starter_pokemons/gen6/froakie.png",
    ],
    'alola': [
      "assets/images/regions/starter_pokemons/gen7/rowlet.png",
      "assets/images/regions/starter_pokemons/gen7/litten.png",
      "assets/images/regions/starter_pokemons/gen7/popplio.png",
    ],
    'galar': [
      "assets/images/regions/starter_pokemons/gen8/grookey.png",
      "assets/images/regions/starter_pokemons/gen8/scorbunny.png",
      "assets/images/regions/starter_pokemons/gen8/sobble.png",
    ],
    'hisui': [],
    'paldea': [
      /*
      "assets/images/regions/starter_pokemons/gen8/grookey.png",
      "assets/images/regions/starter_pokemons/gen8/scorbunny.png",
      "assets/images/regions/starter_pokemons/gen8/sobble.png",
      */
    ],
  };

  static List<String> getStarterPokemons(String region) {
    return starterPokemons[region.toLowerCase()] ??
        [
          /*
          "assets/images/regions/starter_pokemons/gen8/grookey.png",
          "assets/images/regions/starter_pokemons/gen8/grookey.png",
          "assets/images/regions/starter_pokemons/gen8/grookey.png",
          */
        ];
  }
}

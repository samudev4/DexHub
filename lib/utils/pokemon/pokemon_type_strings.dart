String typeEngToEsp(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return "Planta";
      case 'poison':
        return "Veneno";
      case 'fire':
        return "Fuego";
      case 'water':
        return "Agua";
      case 'electric':
        return "Eléctrico";
      case 'dragon':
        return "Dragón";
      case 'fairy':
        return "Hada";
      case 'ghost':
        return "Fantasma";
      case 'ice':
        return "Hielo";
      case 'bug':
        return "Bicho";
      case 'fighting':
        return "Lucha";
      case 'normal':
        return "Normal";
      case 'steel':
        return "Acero";
      case 'rock':
        return "Roca";
      case 'psychic':
        return "Psíquico";
      case 'dark':
        return "Siniestro";
      case 'ground':
        return "Tierra";
      case 'flying':
        return "Volador";
      default:
        return "Desconocido";
    }
  }
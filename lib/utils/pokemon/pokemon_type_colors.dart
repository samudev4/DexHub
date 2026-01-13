import 'package:flutter/material.dart';

class PokemonTypeColors {
  static const Map<String, Color> colors = {
    'grass': Color(0xFF63BC5A),
    'water': Color(0xFF5090D6),
    'dragon': Color(0XFF0B6DC3),
    'electric': Color(0xFFF4D23C),
    'fairy': Color(0XFFEC8FE6),
    'ghost': Color(0xFF5269AD),
    'fire': Color(0xFFFF9D55),
    'ice': Color(0xFF73CEC0),
    'bug': Color(0xFF91C12F),
    'fighting': Color(0xFFCE416B),
    'normal': Color(0xFF919AA2),
    'dark': Color(0xFF5A5465),
    'steel': Color(0xFF5A8EA2),
    'rock': Color(0xFFC5B78C),
    'psychic': Color(0xFFFA7179),
    'ground': Color(0xFFD97845),
    'poison': Color(0xFFB567CE),
    'flying': Color(0xFF89AAE3),
  };

  static Color getColor(String type) {
    return colors[type] ?? Color(0xFF333333);
  }
}

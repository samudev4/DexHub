import 'package:flutter/material.dart';

class PokemonTypeBackgroundCardColor {
  static const Map<String, Color> colors = {
    'grass': Color(0xFFEDF6EC),
    'water': Color(0xFFEBF1F8),
    'dragon': Color(0XFFE4EEF6),
    'electric': Color(0xFFFBF8E9),
    'fairy': Color(0XFFFBF1FA),
    'ghost': Color(0xFFEBEDF4),
    'fire': Color(0xFFFCF3EB),
    'ice': Color(0xFFF1FBF9),
    'bug': Color(0xFFF1F6E8),
    'fighting': Color(0xFFF8E9EE),
    'normal': Color(0xFFF1F2F3),
    'dark': Color(0xFFECEBED),
    'steel': Color(0xFFECF1F3),
    'rock': Color(0xFFF7F5F1),
    'psychic': Color(0xFFFCEEEF),
    'ground': Color(0xFFF9EFEA),
    'poison': Color(0xFFF5EDF8),
    'flying': Color(0xFFF1F4FA),
  };

  static Color getColor(String type) {
    return colors[type] ?? Color(0xFF919AA2);
  }
}

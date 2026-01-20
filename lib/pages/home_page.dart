// ignore_for_file: use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:dexhub/pages/auth/account_gate.dart';
import 'package:dexhub/pages/auth/favorites_gate.dart';
import 'package:dexhub/pages/pokedex_page.dart';
import 'package:dexhub/pages/region_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double _iconSize = 28;
  final double _liftAmount = 10;

  int _currentIndex = 0; // ✅ dentro del state, no global

  final List<Widget> _pages = const [
    PokedexPage(),
    RegionPage(),
    FavoritesGate(),
    AccountGate(),
  ];

  final List<Map<String, String>> _icons = [
    {
      'inactive': AppStrings.rutaPokeballOff,
      'active': AppStrings.rutaPokeballOn,
    },
    {'inactive': AppStrings.rutaPokepinOff, 'active': AppStrings.rutaPokepinOn},
    {
      'inactive': AppStrings.rutaPokeHeartOff,
      'active': AppStrings.rutaPokeHeartOn,
    },
    {'inactive': AppStrings.rutaAccountOff, 'active': AppStrings.rutaAccountOn},
  ];

  final List<String> _labels = [
    AppStrings.textoPokedex,
    AppStrings.textoRegiones,
    AppStrings.textoFavoritos,
    AppStrings.textoCuenta,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ IndexedStack mantiene el estado de cada pestaña
      body: IndexedStack(index: _currentIndex, children: _pages),

      // 👇 CONTENEDOR CON LÍNEA SUPERIOR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black.withOpacity(0.1), // línea visible
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          backgroundColor: AppColors.colorFondoNavigationBar(context),
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          selectedIndex: _currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF173EA5),
              );
            }
            return const TextStyle(fontSize: 11, color: Colors.grey);
          }),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: List.generate(_icons.length, (index) {
            final bool isSelected = _currentIndex == index;

            return NavigationDestination(
              label: _labels[index],
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(
                  0,
                  isSelected ? -_liftAmount : 0,
                  0,
                ),
                child: Image.asset(
                  isSelected
                      ? _icons[index]['active']!
                      : _icons[index]['inactive']!,
                  width: _iconSize,
                  height: _iconSize,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

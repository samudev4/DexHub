import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:dexhub/widgets/region_card.dart';
import 'package:flutter/material.dart';
import 'package:dexhub/models/region_model.dart';
import 'package:dexhub/services/region_service.dart';
import 'package:google_fonts/google_fonts.dart';

class RegionPage extends StatefulWidget {
  const RegionPage({super.key});

  @override
  State<RegionPage> createState() => _RegionPageState();
}

class _RegionPageState extends State<RegionPage> {
  late Future<List<RegionModel>> _regionsFuture;
  final RegionService _regionService = RegionService();

  @override
  void initState() {
    super.initState();
    _regionsFuture = _regionService.getRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondoScaffold(context),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.colorFondoAppBar(context),
        title: Text(
          AppStrings.textoRegiones,
          style: GoogleFonts.poppins(
            color: AppColors.colorTextoPantallasPrincipales(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<RegionModel>>(
        future: _regionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("${AppStrings.textoError}${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(AppStrings.textoNoSeEncontraronRegiones),
            );
          } else {
            final regions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: regions.length,
              itemBuilder: (context, index) {
                final region = regions[index];
                return RegionCard(region: region);
              },
            );
          }
        },
      ),
    );
  }
}

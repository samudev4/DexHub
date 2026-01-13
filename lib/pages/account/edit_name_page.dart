// ignore_for_file: use_build_context_synchronously

import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:dexhub/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class EditNamePage extends StatefulWidget {
  final String currentName;

  const EditNamePage({super.key, required this.currentName});

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  late TextEditingController _nameController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _loading = true);

    final authController = Provider.of<AuthController>(context, listen: false);

    final success = await authController.updateName(newName);

    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context); // volver a AccountPage
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.textoErrorAlActualizarNombre)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondoScaffold(context),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.colorTexto(context),
            ),
          ),
        ),
        title: Text(
          AppStrings.textoEditarNombre,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.colorTexto(context),
          ),
        ),
        backgroundColor: AppColors.colorFondoAppBar(context),
      ),
      body: Center(
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 45),
                Text(
                  textAlign: TextAlign.center,
                  AppStrings.textoCambiaTuNombre,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.colorTexto(context),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Container(
                    height: 58,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF999999), width: 2),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _nameController,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: AppStrings.textoNuevoNombre,
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.colorTexto(context),
                          ),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Icon(
                              Ionicons.person_outline,
                              size: 24,
                              color: AppColors.colorTexto(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 52),
                _loading
                    ? CircularProgressIndicator()
                    : GestureDetector(
                        onTap: () {
                          _saveName();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Container(
                            height: 68,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Color(0xFF173EA5),
                            ),
                            child: Center(
                              child: Text(
                                AppStrings.textoGuardar,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

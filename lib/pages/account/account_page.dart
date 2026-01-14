// ignore_for_file: use_build_context_synchronously

import 'package:dexhub/constants/app_colors.dart';
import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:dexhub/controllers/auth_controller.dart';
import 'package:dexhub/pages/account/edit_name_page.dart';
import 'package:dexhub/theme/theme_provider.dart';
import 'package:dexhub/utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toastification/toastification.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _appVersion = info.version; // ✅ versionName
      // Si quieres también buildNumber:
      _appVersion = "${info.version} (${info.buildNumber})";
    });
  }

  void _showDeleteAccountSheet(
    BuildContext context,
    AuthController authController,
  ) {
    final isDark = context.read<ThemeProvider>().isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Text(
                "¿Eliminar cuenta?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.colorTexto(context),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "Esta acción es permanente y eliminará tu cuenta y datos asociados.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.colorTexto(context),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await authController.deleteAccount();
                      Navigator.of(ctx).pop();
                      toastification.show(
                        title: Text("Cuenta eliminada"),
                        description: Text(
                          "Tu cuenta se ha eliminado correctamente",
                        ),
                        type: ToastificationType.success,
                        style: ToastificationStyle.flatColored,
                        autoCloseDuration: Duration(seconds: 3),
                        showProgressBar: true,
                      );
                    } catch (e) {
                      Navigator.of(ctx).pop();

                      if (e.toString().contains("requires-recent-login")) {
                        toastification.show(
                          title: Text("Inicio de sesión requerido"),
                          description: Text(
                            "Por seguridad, inicia sesión de nuevo y vuelve a intentarlo",
                          ),
                          type: ToastificationType.info,
                          style: ToastificationStyle.flatColored,
                          autoCloseDuration: Duration(seconds: 4),
                          showProgressBar: true,
                        );

                        // ✅ opcional recomendado
                        await authController.logout();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No se pudo eliminar la cuenta"),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCD3131),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    "Sí, eliminar",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Text(
                  "No, cancelar",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.colorTexto(context),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.user;

    final themeProvider = context.read<ThemeProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.colorFondoAppBar(context),
          centerTitle: true,
          scrolledUnderElevation: 0,
          title: Text(
            AppStrings.textoCuenta,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.colorTexto(context),
            ),
          ),
        ),
        backgroundColor: AppColors.colorFondoScaffold(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 25),
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Image.asset(
                              AppStrings.rutaImagenAvatar,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Consumer<AuthController>(
                          builder: (context, auth, _) {
                            return Text(
                              auth.user?.name ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.colorTexto(context),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    Text(
                      AppStrings.textoInformacionDeLaCuenta,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorTexto(context),
                      ),
                    ),

                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditNamePage(currentName: user.name!),
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoNombre,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      leading: Icon(
                        Ionicons.person_outline,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      subtitle: Consumer<AuthController>(
                        builder: (context, auth, _) {
                          return Text(
                            auth.user?.name ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: AppColors.colorTexto(context),
                            ),
                          );
                        },
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: AppColors.colorTexto(context),
                      ),
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      leading: Icon(
                        Ionicons.mail_outline,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      subtitle: Consumer<AuthController>(
                        builder: (context, auth, _) {
                          return Text(
                            auth.user?.email ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: AppColors.colorTexto(context),
                            ),
                          );
                        },
                      ),
                    ),

                    ListTile(
                      leading: Icon(
                        Ionicons.key_outline,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoContrasena,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.contrasena,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      AppStrings.textoApariencia,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorTexto(context),
                      ),
                    ),

                    SwitchListTile(
                      secondary: Icon(
                        Ionicons.moon_outline,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      contentPadding: EdgeInsets.zero,
                      value: isDark,
                      onChanged: (value) => themeProvider.toggleTheme(value),
                      title: Text(
                        AppStrings.textoModoOscuro,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.textoActivaElModoOscuro,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      AppStrings.textoGeneral,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorTexto(context),
                      ),
                    ),

                    // ✅ VERSION REAL
                    ListTile(
                      leading: Icon(
                        Ionicons.information_circle_outline,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoVersion,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      subtitle: Text(
                        _appVersion.isEmpty ? "..." : _appVersion,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),

                    ListTile(
                      onTap: () => UrlUtils.openPrivaciPolicy(),
                      leading: Icon(
                        Icons.policy_outlined,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoPoliticaDePrivacidad,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      subtitle: Text(
                        AppStrings
                            .textoEchaUnVistazoANuestraPoliticaDePrivacidad,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),

                    ListTile(
                      onTap: () => UrlUtils.sendEmail(AppStrings.correoSamu),
                      leading: Icon(
                        Ionicons.help_buoy_outline,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoCentroDeAyuda,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.textoNecesitasAyuda,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),

                    ListTile(
                      onTap: () => UrlUtils.openGitHubRepo(
                        AppStrings.githubUser,
                        AppStrings.textoNombreApp,
                      ),
                      leading: Icon(
                        Ionicons.logo_github,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoDexHubEsDeCodigoAbierto,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.textoPuedesVerTodoElCodigoFuente,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),

                    ListTile(
                      onTap: () =>
                          UrlUtils.openGitHubProfile(AppStrings.githubUser),
                      leading: Icon(
                        Ionicons.code_slash_outline,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoAcercaDe,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.textoProyectoDesarrolladoPor,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),

                    ListTile(
                      onTap: () => UrlUtils.openGitHubIssues(
                        AppStrings.githubUser,
                        AppStrings.textoNombreApp,
                      ),
                      leading: Icon(
                        Ionicons.bug_outline,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoInformarDeUnProblema,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.textoHasTenidoAlgunProblema,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () => UrlUtils.openFigmaAutor(),
                      leading: Icon(
                        Ionicons.color_palette_outline,
                        size: 24,
                        color: AppColors.colorTexto(context),
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Diseñador de la UI",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                      subtitle: Text(
                        "Echa un vistazo al perfil de Figma de Junior Saraiva",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      AppStrings.textoOtros,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.colorTexto(context),
                      ),
                    ),

                    ListTile(
                      leading: const Icon(
                        Ionicons.log_out_outline,
                        size: 24,
                        color: Color(0xFFCD3131),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          backgroundColor: isDark
                              ? const Color(0xFF1F1F1F)
                              : const Color(0xFFFFFFFF),
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (BuildContext ctx) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Text(
                                    AppStrings.textoSeguroQueQuieresSalir,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.colorTexto(context),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await authController.logout();
                                        Navigator.of(ctx).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFCD3131,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        AppStrings.textoSiSalir,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  GestureDetector(
                                    onTap: () => Navigator.of(ctx).pop(),
                                    child: Text(
                                      AppStrings.textoNoCancelar,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.colorTexto(context),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.textoCerrarSesion,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFCD3131),
                        ),
                      ),
                      subtitle: Text(
                        //"Estás conectado como ${authController.user?.name ?? ''}",
                        "${AppStrings.textoEstasConectadoComo}${authController.user?.name ?? ''}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        size: 24,
                        color: Color(0xFFCD3131),
                      ),
                      onTap: () =>
                          _showDeleteAccountSheet(context, authController),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Eliminar cuenta",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFCD3131),
                        ),
                      ),
                      subtitle: Text(
                        "Elimina permanentemente tu cuenta y tus datos",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.colorTexto(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

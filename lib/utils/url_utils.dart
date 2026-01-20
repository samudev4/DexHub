import 'package:dexhub/constants/strings/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlUtils {
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("${AppStrings.textoNoSePudoAbrirLaUrl}$url");
    }
  }

  // --- ENVIAR EMAIL ---
  static Future<void> sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    if (!await launchUrl(emailUri)) {
      throw Exception(AppStrings.textoNoSePudoAbrirLaAppDeCorreo);
    }
  }

  // --- GITHUB LINKS ---
  static Future<void> openGitHubProfile(String username) {
    return openUrl("https://www.github.com/$username");
  }

  static Future<void> openGitHubRepo(String username, String repo) {
    return openUrl("${AppStrings.githubUrl}$username$repo");
  }

  static Future<void> openGitHubIssues(String username, String repo) {
    return openUrl("${AppStrings.githubUrl}$username$repo/issues");
  }

  // --- FIGMA AUTOR ---

  static Future<void> openFigmaAutor() {
    return openUrl("https://www.figma.com/@juniorsaraiva");
  }

  // --- POLÍTICA DE PRIVACIDAD ---

  static Future<void> openPrivaciPolicy() {
    return openUrl("https://sites.google.com/view/polticadeprivacidad-dexhub");
  }

}

import 'package:url_launcher/url_launcher.dart';

/// Membuka tautan web (Google Maps, WhatsApp, Instagram) di aplikasi terkait atau peramban.
///
/// Hanya http(s) yang diizinkan. Mengembalikan false bila tautan tidak valid atau
/// tidak ada aplikasi yang bisa membukanya.
Future<bool> openExternalUrl(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
    return false;
  }
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

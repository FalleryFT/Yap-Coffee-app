import 'package:flutter/material.dart';

import 'app.dart';
import 'core/navigation/app_navigation.dart';
import 'core/storage/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sudah punya token: langsung ke Home, selain itu ke Login.
  // Dibungkus try-catch agar flutter_secure_storage yang gagal di web
  // tidak mencegah runApp() terpanggil (blank screen).
  String? token;
  try {
    token = await TokenStorage.instance.read();
  } catch (_) {
    token = null;
  }
  final hasSession = token != null && token.isNotEmpty;

  runApp(
    YapCoffeeApp(initialRoute: hasSession ? AppRoutes.home : AppRoutes.login),
  );
}

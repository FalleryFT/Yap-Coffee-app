import 'package:flutter/material.dart';

import 'app.dart';
import 'core/navigation/app_navigation.dart';
import 'core/storage/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sudah punya token: langsung ke Home, selain itu ke Login.
  final token = await TokenStorage.instance.read();
  final hasSession = token != null && token.isNotEmpty;

  runApp(
    YapCoffeeApp(initialRoute: hasSession ? AppRoutes.home : AppRoutes.login),
  );
}

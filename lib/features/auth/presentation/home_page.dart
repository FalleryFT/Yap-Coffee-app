import 'package:flutter/material.dart';

import '../../home/presentation/main_shell_page.dart';

/// Halaman Home utama aplikasi Yap Coffee.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShellPage(initialIndex: 0);
  }
}

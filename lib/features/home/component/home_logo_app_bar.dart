import 'package:flutter/material.dart';

/// Baris logo di bagian paling atas halaman Home.
class HomeLogoAppBar extends StatelessWidget {
  const HomeLogoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
      child: Row(
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            height: 28,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

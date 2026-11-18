import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Logo + judul halaman Menu.
class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 14),
          const Text(
            'Menu Kopi',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih racikan kopi terbaik untuk harimu.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

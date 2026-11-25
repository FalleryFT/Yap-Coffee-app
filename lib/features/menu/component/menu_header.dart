import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';

/// Logo + judul halaman Menu.
class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Text(
              'Menu Kopi',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Text(
              'Pilih racikan kopi terbaik untuk harimu.',
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
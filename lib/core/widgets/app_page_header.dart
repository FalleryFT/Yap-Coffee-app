import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Header halaman sederhana: tombol kembali bulat + judul.
/// Dipakai halaman Edit Profil dan halaman lain yang tidak memakai AppBar.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.icon = Icons.arrow_back_rounded,
  });

  final String title;
  final VoidCallback onBack;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.buttonDark,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

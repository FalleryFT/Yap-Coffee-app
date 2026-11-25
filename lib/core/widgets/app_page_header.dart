import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Header halaman sederhana: tombol kembali bulat + judul, dengan
/// [trailing] opsional di pojok kanan.
/// Dipakai halaman Edit Profil dan halaman lain yang tidak memakai AppBar.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.icon = Icons.arrow_back_rounded,
    this.trailing,
  });

  final String title;
  final VoidCallback onBack;
  final IconData icon;
  final Widget? trailing;

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
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}
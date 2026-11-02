import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Judul + subjudul halaman autentikasi (login, daftar, lupa sandi, dsb.).
/// Menghindari penulisan ulang TextStyle yang sama di setiap halaman.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.fontSize = 28,
    this.spacing = 8,
  });

  final String title;
  final String? subtitle;
  final double fontSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.espresso,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: spacing),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.bark),
          ),
        ],
      ],
    );
  }
}

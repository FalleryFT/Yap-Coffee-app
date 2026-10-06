import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Baris penutup kartu, contoh: "Belum punya akun? Daftar sekarang".
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  final String prompt;
  final String actionLabel;

  /// Null berarti tautan nonaktif (tampil abu-abu).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(prompt, style: const TextStyle(fontSize: 14)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              actionLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: onTap == null ? AppColors.hint : AppColors.espresso,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

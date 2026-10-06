import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.espresso,
        primary: AppColors.espresso,
        surface: Colors.white,
        error: AppColors.danger,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      // Plus Jakarta Sans diunduh saat pertama kali dipakai (perlu internet).
      // Untuk aplikasi rilis, sertakan berkas font sebagai aset agar bisa offline.
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.bark,
        displayColor: AppColors.espresso,
      ),
    );
  }
}

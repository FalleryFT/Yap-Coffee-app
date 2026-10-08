import 'package:flutter/material.dart';

/// Token warna dari desain Figma (Login.svg, Sign-in.svg, dst).
/// Padanan Tailwind di web-admin ada di src/index.css (@theme).
class AppColors {
  AppColors._();

  static const Color cream = Color(0xFFFBF9F4); // latar layar, kotak OTP
  static const Color espresso = Color(0xFF432406); // tombol, judul
  static const Color mocha = Color(0xFF7D562D); // tautan "Lupa Password?"
  static const Color ink = Color(0xFF1B1C19); // label dan isi input
  static const Color bark = Color(0xFF50453C); // teks isi dan ikon
  static const Color hint = Color(0xFF6B7280); // placeholder
  static const Color line = Color(0xFFE6CCB2); // garis tepi input
  static const Color cardLine = Color(0xFFEAE8E3); // garis tepi kartu
  static const Color peach = Color(0xFFFFDCC2); // lingkaran ikon di Login
  static const Color danger = Color(0xFFB3261E);
  static const Color heroBrown = Color(0xFF543928);
  static const Color statusBg = Color(0xFFEDE9E2);
  static const Color statusOlive = Color(0xFF435436);
  static const Color chipBrown = Color(0xFF785135);
  static const Color buttonPeach = Color(0xFFE2C4AE);
  static const Color buttonDark = Color(0xFF381F0E);
  static const Color textMuted = Color(0xFF766A5F);
  static const Color textDark = Color(0xFF2C190D);
}

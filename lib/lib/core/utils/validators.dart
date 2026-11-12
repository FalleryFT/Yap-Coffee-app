import 'package:flutter/widgets.dart';

/// Validator sisi klien. Validasi resmi tetap ada di backend.
class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? notEmpty(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi.';
    return null;
  }

  static String? email(String? value) {
    final empty = notEmpty(value, 'Email');
    if (empty != null) return empty;
    return _email.hasMatch(value!.trim()) ? null : 'Format email belum benar.';
  }

  static String? newPassword(String? value) {
    final empty = notEmpty(value, 'Kata sandi');
    if (empty != null) return empty;
    return value!.length >= 8 ? null : 'Kata sandi minimal 8 karakter.';
  }

  /// Membuat validator yang membandingkan isi kolom dengan [original].
  static String? Function(String?) confirmation(TextEditingController original) {
    return (String? value) {
      final empty = notEmpty(value, 'Konfirmasi sandi');
      if (empty != null) return empty;
      return value == original.text ? null : 'Konfirmasi sandi tidak sama.';
    };
  }

  /// Nomor ponsel Indonesia tanpa kode negara, 9 sampai 13 digit.
  static String? phone(String? value) {
    final empty = notEmpty(value, 'Nomor ponsel');
    if (empty != null) return empty;
    final digits = phoneDigits(value!);
    return (digits.length >= 9 && digits.length <= 13)
        ? null
        : 'Nomor ponsel belum benar.';
  }

  /// Menghapus semua karakter non-angka serta awalan 62 atau 0.
  /// Contoh: "0812 3456 7890" dan "+62 812 3456 7890" sama-sama menjadi "81234567890".
  static String phoneDigits(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  /// Format yang dikirim ke API, contoh: +6281234567890
  static String toInternationalPhone(String input) => '+62${phoneDigits(input)}';
}

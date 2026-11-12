import 'package:flutter/foundation.dart';

/// Pusat pembersihan data milik pengguna saat keluar (logout atau sesi berakhir),
/// supaya pengguna berikutnya di perangkat yang sama tidak melihat pesanan atau
/// keranjang pengguna sebelumnya. Setiap store mendaftarkan pembersihnya sendiri.
class AppSession {
  AppSession._();

  static final List<VoidCallback> _resetters = [];

  static void registerResetter(VoidCallback resetter) => _resetters.add(resetter);

  static void reset() {
    for (final resetter in _resetters) {
      resetter();
    }
  }
}

import 'package:flutter/material.dart';

/// Tinggi area header yang harus dihindari tombol melayang
/// ([FloatingButtonsLayer]) di tiap tab utama, di bawah status bar.
///
/// Hanya Home yang punya header tetap (logo + lonceng); tab lain bebas.
/// Kalau tinggi header Home diubah, ubah juga angkanya di sini.
abstract final class AppHeaderMetrics {
  static const double logoHeight = 36;

  /// Home: baris logo + lonceng, tetap di atas saat konten di-scroll.
  static const double home = 52;

  /// Tinggi area atas yang dihindari tombol melayang untuk indeks tab
  /// MainShellPage (0 = Home, 1 = Menu, 2 = Orders, 3 = Profil).
  static double forTab(int index) => index == 0 ? home : 0;
}

/// Logo "yap coffee" lengkap. Memakai file yang punya ruang kosong di
/// sekelilingnya, jadi lingkarannya tidak terpotong. Latar file ini sama
/// dengan AppColors.cream, pakai hanya di atas latar cream.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = AppHeaderMetrics.logoHeight});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/yap_coffee_logo.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

/// Emblem bulat (lingkaran + ikon) yang diambil dari bagian kiri logo,
/// lengkap dengan lingkaran luarnya.
class AppEmblem extends StatelessWidget {
  const AppEmblem({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 0.27,
        heightFactor: 0.9,
        child: Image.asset(
          'assets/images/yap_coffee_logo.png',
          height: size / 0.9,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
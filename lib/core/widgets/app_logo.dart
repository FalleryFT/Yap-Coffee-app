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

  /// Lebar file logo terhadap tingginya (180x43).
  static const double _logoAspectRatio = 180 / 43;

  /// Lingkaran emblem menempel ke tepi file logo, jadi gambar diperkecil
  /// sedikit di dalam kotak [size] supaya lingkarannya tidak terpotong.
  static const double _scale = 0.92;

  @override
  Widget build(BuildContext context) {
    // Kalau hanya tinggi gambar yang diatur, lebarnya ikut dipaksa selebar
    // kotak [size], sehingga seluruh logo mengecil dan emblemnya terpotong.
    // Jadi gambar digambar pada ukuran aslinya (melebihi kotak) lewat
    // OverflowBox, lalu dipotong di kotak persegi [size].
    final double imageHeight = size * _scale;
    final double imageWidth = imageHeight * _logoAspectRatio;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: imageWidth,
          maxWidth: imageWidth,
          minHeight: imageHeight,
          maxHeight: imageHeight,
          child: Image.asset(
            'assets/images/yap_coffee_logo.png',
            width: imageWidth,
            height: imageHeight,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
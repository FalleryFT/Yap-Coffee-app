import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Gambar menu: foto unggahan admin (dari [url]) atau gambar bawaan aplikasi (dari [asset]).
/// Bila gagal dimuat atau tidak ada, tampil ikon kopi sebagai pengganti.
class CoffeeImage extends StatelessWidget {
  const CoffeeImage({
    super.key,
    required this.asset,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String asset;
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0EEE9),
      alignment: Alignment.center,
      child: const Icon(Icons.coffee_rounded, color: AppColors.bark, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remote = url;
    if (remote != null && remote.isNotEmpty) {
      return Image.network(
        remote,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (asset.isEmpty) return _placeholder();
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }
}

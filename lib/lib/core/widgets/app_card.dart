import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Kotak putih bergaris tipis dengan bayangan lembut. Dipakai di hampir
/// semua halaman (keranjang, checkout, pesanan, profil, pembayaran).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.color = Colors.white,
    this.borderColor = AppColors.cardLine,
    this.showShadow = true,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color? borderColor;
  final bool showShadow;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

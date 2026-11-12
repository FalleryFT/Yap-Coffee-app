import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../data/store_links.dart';

/// Banner utama berisi sapaan, tagline, dan tombol aksi.
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    this.firstName = '',
    this.instagram = '',
  });

  /// Nama depan pelanggan (dari GET /api/home). Kosong: sapaan umum.
  final String firstName;

  /// Akun Instagram toko (dari GET /api/home). Kosong: nilai bawaan.
  final String instagram;

  String get _greeting =>
      firstName.isEmpty ? 'Haloo Pelanggan 👋' : 'Haloo, $firstName 👋';

  String get _instagram => instagram.isEmpty ? '@yappcoffee' : instagram;

  void _onContactSeller(BuildContext context) {
    StoreLinks.openWhatsapp(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.heroBrown,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & 100% Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x40000000),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _greeting,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC4A482),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        '100% Kopi Asli & Aren',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFDCC8B4),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Title
          const Text(
            'yapp coffee',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Seduhan kopi berkarakter dengan harga bersahabat dan racikan khas Nusantara.',
            style: TextStyle(
              fontSize: 12.2,
              color: Color(0xFFD8C3AF),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Dashed Divider
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: const _DashedLinePainter(color: Color(0x38FFFFFF)),
          ),
          const SizedBox(height: 14),

          // Action Buttons: "Hubungi Penjual" & "@yappcoffee"
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onContactSeller(context),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBE6DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Color(0xFF2B180D),
                          size: 17,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Hubungi Penjual',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF2B180D),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => StoreLinks.openInstagram(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x28000000),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x35FFFFFF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _instagram,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

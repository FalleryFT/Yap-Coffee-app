import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';

/// Kartu peta titik pengambilan (peta statis tanpa package maps).
class PickupMapCard extends StatelessWidget {
  const PickupMapCard({
    super.key,
    required this.routeGuide,
    required this.onOpenMaps,
  });

  final String routeGuide;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, size: 9, color: Color(0xFF1DB87A)),
                  SizedBox(width: 8),
                  Text(
                    'Peta Titik Pengambilan',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onOpenMaps,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EBE0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE6D3C0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Buka di Google Maps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 12,
                        color: AppColors.textDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const PickupMapPreview(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF4EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFECE0D2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2E2D4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alt_route_rounded,
                    size: 17,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patokan Rute Pengambilan:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        routeGuide,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.bark,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onOpenMaps,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Buka Penunjuk Arah (Navigasi Maps)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pratinjau peta statis (ilustrasi desain).
class PickupMapPreview extends StatelessWidget {
  const PickupMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: PickupMapPainter())),
            const Positioned(
              left: 14,
              top: 54,
              child: Text(
                'Taman Sipil',
                style: TextStyle(fontSize: 9, color: Color(0xFF6B7A5A)),
              ),
            ),
            const Positioned(
              right: 22,
              top: 18,
              child: Text(
                'Gedung FT',
                style: TextStyle(fontSize: 9, color: Color(0xFF7A6E5E)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 52,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.buttonDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 7, color: Color(0xFFFFC107)),
                        SizedBox(width: 6),
                        Text(
                          'Gazebo Sipil – Drop Point Yap Coffee',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 36,
                    color: Color(0xFFD32F2F),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 4),
                  ],
                ),
                child: const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.add, size: 16, color: AppColors.bark),
                    ),
                    SizedBox(
                      width: 22,
                      child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.remove, size: 16, color: AppColors.bark),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Google',
                  style: TextStyle(fontSize: 9, color: Color(0xFF5F6368)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Peta statis sederhana (tanpa package maps) untuk tampilan desain.
class PickupMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEFE8DB),
    );

    // Taman
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, h * 0.1, w * 0.3, h * 0.45),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFD9E4C8),
    );

    // Gedung FT
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.68, h * 0.05, w * 0.28, h * 0.32),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFE3DACA),
    );

    // Jalan putih
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.52, h), road);
    canvas.drawLine(Offset(0, h * 0.78), Offset(w, h * 0.5), road);

    // Garis putus kuning
    final dash = Paint()
      ..color = const Color(0xFFF2C94C)
      ..strokeWidth = 2.5;
    final start = Offset(0, h * 0.78);
    final end = Offset(w, h * 0.5);
    const segments = 22;
    for (var i = 0; i < segments; i += 2) {
      canvas.drawLine(
        Offset.lerp(start, end, i / segments)!,
        Offset.lerp(start, end, (i + 1) / segments)!,
        dash,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

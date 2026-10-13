import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/order_model.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  void _showMapsSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Membuka Google Maps...'),
        backgroundColor: AppColors.buttonDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 16),
              _buildSummaryCard(),
              const SizedBox(height: 14),
              _buildPickupCard(),
              const SizedBox(height: 14),
              _buildMapCard(context),
              const SizedBox(height: 16),
              const Text(
                'Harap sebutkan nama atau nomor pesanan saat\npengambilan di Gazebo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardLine),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'DETAIL PENGAMBILAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF2E2D4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2C4AE)),
          ),
          child: Text(
            'Order #${order.id}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(order.items.length, (i) {
            final item = order.items[i];
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        item.imageAsset ?? 'assets/images/yap_latte.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              Text(
                                formatRupiah(item.price),
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.notes ?? '-',
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.bark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (i != order.items.length - 1) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFECE7DE)),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFECE7DE)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 14.5, color: AppColors.textDark),
              ),
              Text(
                order.formattedTotal,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Kloter
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EBE0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.batchName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order.pickupDate,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bark,
                        ),
                      ),
                      Text(
                        order.pickupTime.replaceAll(':', '.'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.bark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Titik temu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF4EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFECE0D2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textDark,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'TITIK TEMU PENGAMBILAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  order.pickupPoint,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: AppColors.textDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Detail: ${order.pickupDetail}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE6DACB)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 16,
                      color: AppColors.textDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.pickupArea,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
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
                onTap: () => _showMapsSnack(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EBE0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE6D3C0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
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
          _buildMapPreview(),
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
                        order.routeGuide,
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
              onPressed: () => _showMapsSnack(context),
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

  Widget _buildMapPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MapPainter()),
            ),
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
            // Label + pin
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
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
            // Zoom
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
                child: Column(
                  children: const [
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
                      child:
                          Icon(Icons.remove, size: 16, color: AppColors.bark),
                    ),
                  ],
                ),
              ),
            ),
            // Google badge
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.cardLine),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    );
  }
}

/// Peta statis sederhana (tanpa package maps) untuk tampilan desain.
class _MapPainter extends CustomPainter {
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
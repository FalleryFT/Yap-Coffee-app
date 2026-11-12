import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../orders/data/order_model.dart';

/// Kartu status pesanan aktif ("Siap Diambil").
class HomeActiveOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onAmbilTapped;

  const HomeActiveOrderCard({
    super.key,
    required this.order,
    this.onAmbilTapped,
  });

  String get _itemsSummary {
    if (order.items.isEmpty) return order.batchName;
    final first = order.items.first;
    final items = '${first.qty}× ${first.name}';
    if (order.batchName.isEmpty) return items;
    return '$items • ${order.batchName}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.statusBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD7CC)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF435436),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Siap Diambil',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF435436),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCD6CC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${order.id}',
                        style: const TextStyle(
                          color: Color(0xFF5A5248),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _itemsSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5A5248),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAmbilTapped,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.buttonDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Ambil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

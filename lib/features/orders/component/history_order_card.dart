import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_card.dart';
import '../data/order_model.dart';
import 'order_status_chip.dart';

/// Kartu pesanan pada tab riwayat (selesai / dibatalkan).
class HistoryOrderCard extends StatelessWidget {
  const HistoryOrderCard({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.dibatalkan;
    final textColor = isCancelled ? AppColors.textMuted : AppColors.textDark;

    return AppCard(
      color: isCancelled ? const Color(0xFFFCF7F2) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.dateLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: isCancelled ? AppColors.textMuted : AppColors.bark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.id,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              OrderStatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFECE7DE)),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${item.qty}x ',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: item.name),
                        ],
                      ),
                      style: TextStyle(fontSize: 13.5, color: textColor),
                    ),
                  ),
                  Text(
                    rupiah(item.price),
                    style: TextStyle(
                      fontSize: 13,
                      color: isCancelled ? AppColors.textMuted : AppColors.bark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, color: Color(0xFFECE7DE)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Total Belanja',
                style: TextStyle(
                  fontSize: 13.5,
                  color: isCancelled ? AppColors.textMuted : AppColors.bark,
                ),
              ),
              Text(
                order.formattedTotal,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

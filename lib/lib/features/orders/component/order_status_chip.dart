import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/order_model.dart';

/// Label status pesanan berwarna sesuai keadaan.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;

    switch (status) {
      case OrderStatus.belumDibayar:
        bg = const Color(0xFFFF8A8A);
        fg = AppColors.textDark;
        icon = Icons.payments_outlined;
        label = 'Belum Dibayar';
      case OrderStatus.menunggu:
        bg = const Color(0xFFF2E2D4);
        fg = AppColors.textDark;
        icon = Icons.hourglass_empty_rounded;
        label = 'Menunggu Diproses';
      case OrderStatus.diproses:
        bg = const Color(0xFFF6D9A8);
        fg = AppColors.textDark;
        icon = Icons.local_cafe_outlined;
        label = 'Sedang Diproses';
      case OrderStatus.siapDiambil:
        bg = const Color(0xFFDDE6BC);
        fg = AppColors.textDark;
        icon = Icons.shopping_bag_outlined;
        label = 'Siap Diambil';
      case OrderStatus.selesai:
        bg = const Color(0xFFDDE6BC);
        fg = AppColors.textDark;
        icon = Icons.check_circle_rounded;
        label = 'Selesai';
      case OrderStatus.dibatalkan:
        bg = const Color(0xFFFBDAD8);
        fg = const Color(0xFFB3261E);
        icon = Icons.cancel_rounded;
        label = 'Dibatalkan';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          (status == OrderStatus.belumDibayar || status == OrderStatus.menunggu)
              ? 6
              : 16,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

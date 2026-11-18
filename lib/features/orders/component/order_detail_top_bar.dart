import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OrderDetailTopBar extends StatelessWidget {
  const OrderDetailTopBar({super.key, required this.orderId, required this.onBack});

  final String orderId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
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
            'Order #$orderId',
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
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';

/// Kartu batas waktu pembayaran dengan hitungan mundur.
class PaymentDeadlineCard extends StatelessWidget {
  const PaymentDeadlineCard({super.key, required this.timerText});

  final String timerText;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 22, color: AppColors.espresso),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BATAS PEMBAYARAN',
                  style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 0.4,
                    color: AppColors.bark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Selesaikan dalam 10 menit',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.buttonDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 15, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  timerText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

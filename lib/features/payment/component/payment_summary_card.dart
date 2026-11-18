import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';

/// Ringkasan baris pesanan pada halaman pembayaran.
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.orderLines});

  final List<String> orderLines;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: AppColors.line),
          const SizedBox(height: 12),
          for (final line in orderLines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                line,
                style: const TextStyle(fontSize: 14.5, color: AppColors.ink),
              ),
            ),
        ],
      ),
    );
  }
}

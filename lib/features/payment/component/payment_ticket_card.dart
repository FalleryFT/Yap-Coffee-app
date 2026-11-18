import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Kartu tiket: strip cokelat di atas, nomor antrean, [child], nama pemesan.
class PaymentTicketCard extends StatelessWidget {
  const PaymentTicketCard({
    super.key,
    required this.queueNumber,
    required this.customerName,
    required this.child,
  });

  final String queueNumber;
  final String customerName;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(93, 58, 26, 0.10),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 9, color: AppColors.chipBrown),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
            child: Column(
              children: [
                const Text(
                  'NOMOR ANTREAN',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    color: AppColors.bark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  queueNumber,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.espresso,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 18),
                child,
                const SizedBox(height: 18),
                const Text(
                  'Pesanan atas nama:',
                  style: TextStyle(fontSize: 14, color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mocha,
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

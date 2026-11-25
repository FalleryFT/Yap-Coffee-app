import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Pengganti kotak QR tiruan: pelanggan memilih metode bayar di halaman Midtrans.
class PaymentMethodBox extends StatelessWidget {
  const PaymentMethodBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 192,
      height: 192,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 44, color: AppColors.espresso),
          SizedBox(height: 12),
          Text(
            'Pilih metode pembayaran',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'QRIS, e-wallet, atau virtual account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: AppColors.bark, height: 1.3),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OrdersHeader extends StatelessWidget {
  const OrdersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/app_emblem.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              'Pesanan Saya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

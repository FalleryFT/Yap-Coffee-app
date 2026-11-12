import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/coffee_image.dart';
import '../../../core/widgets/app_quantity_stepper.dart';
import '../data/coffee_item_model.dart';

/// Ringkasan produk di dalam sheet "Tambahkan Menu": gambar, nama,
/// varian, harga, dan pengatur jumlah.
class SelectedItemSummaryCard extends StatelessWidget {
  const SelectedItemSummaryCard({
    super.key,
    required this.item,
    required this.variant,
    required this.totalPrice,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final CoffeeItem item;
  final String variant;
  final int totalPrice;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final imageToUse = item.modalImageAsset ?? item.imageAsset;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE7DE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CoffeeImage(
              asset: imageToUse,
              url: item.imageUrl,
              width: 76,
              height: 76,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  variant,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rupiah(totalPrice),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    AppQuantityStepper(
                      quantity: quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                      width: 88,
                      height: 32,
                      iconSize: 15,
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
}

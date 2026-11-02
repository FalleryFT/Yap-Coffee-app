import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_card.dart';
import '../../cart/data/cart_manager.dart';

/// Kartu daftar pesanan pada checkout beserta pengatur jumlahnya.
class CheckoutOrderCard extends StatelessWidget {
  const CheckoutOrderCard({
    super.key,
    required this.items,
    required this.onQuantityChanged,
    required this.onAddMore,
  });

  final List<CartItem> items;
  final void Function(CartItem item, int delta) onQuantityChanged;
  final VoidCallback onAddMore;

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
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 1, color: AppColors.cardLine),
              const SizedBox(height: 14),
            ],
            _itemRow(items[i]),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onAddMore,
              icon: const Icon(
                Icons.add_circle_outline,
                size: 24,
                color: AppColors.ink,
              ),
              label: const Text(
                'Tambah Pesanan Lain',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.espresso),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item.imageAsset,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: const Color(0xFFF0EEE9),
              child: const Icon(
                Icons.coffee_rounded,
                color: AppColors.bark,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rupiah(item.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.variant,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, color: AppColors.bark),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _stepperButton(
                    Icons.remove,
                    () => onQuantityChanged(item, -1),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  _stepperButton(Icons.add, () => onQuantityChanged(item, 1)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 16, color: AppColors.espresso),
      ),
    );
  }
}

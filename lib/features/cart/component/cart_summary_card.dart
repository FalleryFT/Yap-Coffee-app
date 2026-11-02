import 'package:flutter/material.dart';

import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_order_summary_card.dart';
import '../data/cart_manager.dart';

/// Ringkasan biaya keranjang (subtotal, pajak, layanan, total).
class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({super.key, required this.cart});

  final CartManager cart;

  @override
  Widget build(BuildContext context) {
    return OrderSummaryCard(
      rows: [
        SummaryRow('Subtotal', rupiah(cart.subtotal)),
        SummaryRow('Pajak (11%)', rupiah(cart.tax)),
        SummaryRow('Biaya Layanan', rupiah(cart.serviceFee)),
      ],
      totalLabel: 'Total',
      totalValue: rupiah(cart.grandTotal),
      titleFontSize: 15.5,
      labelFontSize: 13.5,
      totalFontSize: 18,
    );
  }
}

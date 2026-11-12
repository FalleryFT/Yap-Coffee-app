import 'package:flutter/material.dart';

import '../../../core/widgets/app_empty_state.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key, required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Keranjang Belanja Kosong',
      message: 'Pilih racikan kopi terbaikmu dan tambahkan ke keranjang.',
      actionLabel: 'Mulai Belanja',
      onAction: onShop,
    );
  }
}

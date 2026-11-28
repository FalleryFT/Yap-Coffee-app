import 'package:flutter/material.dart';

import '../../../core/widgets/app_menu_card.dart';
import '../model/coffee_item_model.dart';

/// Grid dua kolom berisi kartu menu.
class MenuGrid extends StatelessWidget {
  const MenuGrid({
    super.key,
    required this.items,
    required this.onItemTapped,
    required this.onAddTapped,
  });

  final List<CoffeeItem> items;

  /// Gambar, nama, atau deskripsi disentuh: buka detail menu.
  final ValueChanged<CoffeeItem> onItemTapped;

  /// Harga atau tanda plus disentuh: tambah ke keranjang.
  final ValueChanged<CoffeeItem> onAddTapped;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 90),
      sliver: SliverGrid(
        // Lebar kartu dibatasi (bukan jumlah kolom tetap) supaya kolom
        // menyesuaikan lebar layar dan teks tidak terpotong saat font besar.
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisExtent: 300,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return AppMenuCard(
              item: item,
              onTap: () => onItemTapped(item),
              onAdd: () => onAddTapped(item),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

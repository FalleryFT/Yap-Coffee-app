import 'package:flutter/material.dart';

import '../../../core/widgets/app_menu_card.dart';
import '../data/coffee_item_model.dart';

/// Grid dua kolom berisi kartu menu.
class MenuGrid extends StatelessWidget {
  const MenuGrid({
    super.key,
    required this.items,
    required this.onItemTapped,
  });

  final List<CoffeeItem> items;
  final ValueChanged<CoffeeItem> onItemTapped;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 90),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
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
              onAdd: () => onItemTapped(item),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

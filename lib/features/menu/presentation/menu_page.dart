import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_filter_chips.dart';
import '../../../core/widgets/app_menu_card.dart';
import '../../../core/widgets/app_search_field.dart';
import '../data/coffee_item_model.dart';
import 'add_to_cart_bottom_sheet.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback? onCartTapped;

  const MenuPage({super.key, this.onCartTapped});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _selectedCategory = 'Semua Kopi';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'Semua Kopi',
    'Espresso-Based',
    'Manual Brew',
    'Non-Coffee',
    'Makanan Ringan',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CoffeeItem> get _filteredItems {
    return CoffeeData.menuCatalog.where((item) {
      final matchesCategory = _selectedCategory == 'Semua Kopi' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: MenuHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: AppSearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppFilterChips(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) =>
                    setState(() => _selectedCategory = category),
                margin: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            MenuGrid(
              items: _filteredItems,
              onItemTapped: (item) => openAddToCartSheet(context, item),
            ),
          ],
        ),
      ),
    );
  }
}

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

/// Logo + judul halaman Menu.
class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 14),
          const Text(
            'Menu Kopi',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih racikan kopi terbaik untuk harimu.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

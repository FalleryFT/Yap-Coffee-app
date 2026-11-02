import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_filter_chips.dart';
import '../../../core/widgets/app_search_field.dart';
import '../component/add_to_cart_sheet.dart';
import '../component/menu_grid.dart';
import '../component/menu_header.dart';
import '../data/coffee_item_model.dart';

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

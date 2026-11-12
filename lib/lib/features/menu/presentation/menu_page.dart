import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_filter_chips.dart';
import '../../../core/widgets/app_search_field.dart';
import '../component/add_to_cart_sheet.dart';
import '../component/menu_grid.dart';
import '../component/menu_header.dart';
import '../data/coffee_item_model.dart';
import '../data/menu_store.dart';
import 'menu_detail_page.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback? onCartTapped;

  const MenuPage({super.key, this.onCartTapped});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  static const String _all = 'Semua Kopi';

  final MenuStore _store = MenuStore.instance;
  String _selectedCategory = _all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.load());
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (!mounted) return;
    // Kategori yang dipilih bisa hilang setelah katalog dimuat ulang.
    if (_selectedCategory != _all &&
        !_store.categories.contains(_selectedCategory)) {
      _selectedCategory = _all;
    }
    setState(() {});
  }

  List<String> get _categories => [_all, ..._store.categories];

  List<CoffeeItem> get _filteredItems {
    final query = _searchQuery.toLowerCase();
    return _store.items.where((item) {
      final matchesCategory = _selectedCategory == _all ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Widget _stateMessage() {
    if (_store.status == LoadStatus.error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Menu belum bisa dimuat',
          message: _store.error,
          actionLabel: 'Coba Lagi',
          onAction: () => _store.load(force: true),
        ),
      );
    }
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator(color: AppColors.espresso)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loaded = _store.status == LoadStatus.ready;
    final items = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.espresso,
          onRefresh: () => _store.load(force: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
              if (loaded) ...[
                SliverToBoxAdapter(
                  child: AppFilterChips(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) =>
                        setState(() => _selectedCategory = category),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Menu tidak ditemukan',
                    ),
                  )
                else
                  MenuGrid(
                    items: items,
                    onItemTapped: (item) => MenuDetailPage.open(context, item),
                    onAddTapped: (item) => openAddToCartSheet(context, item),
                  ),
              ] else
                _stateMessage(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/viewmodel/load_status.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_filter_chips.dart';
import '../../../core/widgets/app_search_field.dart';
import '../component/add_to_cart_sheet.dart';
import '../component/menu_grid.dart';
import '../component/menu_header.dart';
import '../viewmodel/menu_view_model.dart';
import 'menu_detail_page.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback? onCartTapped;

  const MenuPage({super.key, this.onCartTapped});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final MenuViewModel _menu = MenuViewModel.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _menu.load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _stateMessage() {
    if (_menu.status == LoadStatus.error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Menu belum bisa dimuat',
          message: _menu.error,
          actionLabel: 'Coba Lagi',
          onAction: () => _menu.load(force: true),
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
    return ListenableBuilder(
      listenable: _menu,
      builder: (context, _) {
        final loaded = _menu.status == LoadStatus.ready;
        final items = _menu.filteredItems;

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.espresso,
              onRefresh: () => _menu.load(force: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const SliverToBoxAdapter(child: MenuHeader()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: AppSearchField(
                        controller: _searchController,
                        onChanged: _menu.setQuery,
                      ),
                    ),
                  ),
                  if (loaded) ...[
                    SliverToBoxAdapter(
                      child: AppFilterChips(
                        categories: _menu.categoryChips,
                        selectedCategory: _menu.selectedCategory,
                        onCategorySelected: _menu.selectCategory,
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
      },
    );
  }
}

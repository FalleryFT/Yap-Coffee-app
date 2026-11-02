import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_filter_chips.dart';
import '../../../core/widgets/app_menu_card.dart';
import '../../menu/component/add_to_cart_sheet.dart';
import '../../menu/data/coffee_item_model.dart';
import '../../orders/data/order_model.dart';
import '../../orders/presentation/order_detail_page.dart';
import '../component/home_active_order_card.dart';
import '../component/home_hero_card.dart';
import '../component/home_logo_app_bar.dart';
import '../component/home_section_header.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onSeeAllTapped;

  const HomeView({super.key, required this.onSeeAllTapped});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _selectedCategory = 'Semua Kopi';

  final List<String> _categories = const [
    'Semua Kopi',
    'Es Kopi Susu',
    'Manual Brew',
    'Non-Coffee',
    'Makanan Ringan',
  ];

  /// Pesanan terbaru yang sudah siap diambil di outlet.
  OrderModel? get _readyOrder {
    for (final order in OrderData.orders) {
      if (order.status == OrderStatus.belumDiambil) return order;
    }
    return null;
  }

  List<CoffeeItem> get _displayedItems {
    if (_selectedCategory == 'Semua Kopi') {
      return CoffeeData.homeFavorites;
    }
    final filtered = CoffeeData.homeFavorites
        .where((it) => it.category == _selectedCategory)
        .toList();
    if (filtered.isNotEmpty) return filtered;
    return CoffeeData.menuCatalog
        .where((it) => it.category == _selectedCategory)
        .toList();
  }

  void _openReadyOrder(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OrderDetailPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _displayedItems;
    final readyOrder = _readyOrder;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: HomeLogoAppBar()),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: HomeHeroCard(),
              ),
            ),

            if (readyOrder != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: HomeActiveOrderCard(
                    order: readyOrder,
                    onAmbilTapped: () => _openReadyOrder(readyOrder),
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: AppFilterChips(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) =>
                    setState(() => _selectedCategory = category),
                inactiveColor: const Color(0xFFEBE6DF),
                inactiveBorderColor: const Color(0xFFD5CEBF),
                inactiveTextColor: const Color(0xFF3A2414),
              ),
            ),

            SliverToBoxAdapter(
              child: HomeSectionHeader(
                title: 'Menu Favorit Tetangga',
                onActionTapped: widget.onSeeAllTapped,
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
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
                      onTap: () => openAddToCartSheet(context, item),
                      onAdd: () => openAddToCartSheet(context, item),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/viewmodel/load_status.dart';
import '../../../core/widgets/app_filter_chips.dart';
import '../../../core/widgets/app_menu_card.dart';
import '../../menu/component/add_to_cart_sheet.dart';
import '../../menu/view/menu_detail_page.dart';
import '../../menu/viewmodel/menu_view_model.dart';
import '../../orders/model/order_model.dart';
import '../../orders/view/order_detail_page.dart';
import '../component/home_active_order_card.dart';
import '../component/home_hero_card.dart';
import '../component/home_logo_app_bar.dart';
import '../component/home_section_header.dart';
import '../viewmodel/home_view_model.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onSeeAllTapped;

  const HomeView({super.key, required this.onSeeAllTapped});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeViewModel _home = HomeViewModel.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MenuViewModel.instance.load();
      _home.load();
    });
  }

  void _openReadyOrder(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OrderDetailPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _home,
      builder: (context, _) {
        final items = _home.displayedItems;
        final readyOrder = _home.readyOrder;

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: SafeArea(
            child: Column(
              children: [
                // Header logo + lonceng: tetap di atas saat konten di-scroll.
                const HomeLogoAppBar(),

                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: HomeHeroCard(
                            firstName: _home.firstName,
                            instagram: _home.instagramHandle,
                          ),
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
                          categories: _home.categoryChips,
                          selectedCategory: _home.selectedCategory,
                          onCategorySelected: _home.selectCategory,
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

                      if (_home.listStatus == LoadStatus.error)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 24,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _home.listError,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.bark),
                                ),
                                TextButton(
                                  onPressed: _home.retry,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_home.listStatus != LoadStatus.ready)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.espresso,
                              ),
                            ),
                          ),
                        ),

                      SliverPadding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 90,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                onTap: () => MenuDetailPage.open(context, item),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
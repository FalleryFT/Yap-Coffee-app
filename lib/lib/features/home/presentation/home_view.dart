import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_filter_chips.dart';
import '../../../core/widgets/app_menu_card.dart';
import '../../menu/component/add_to_cart_sheet.dart';
import '../../menu/data/coffee_item_model.dart';
import '../../menu/data/menu_store.dart';
import '../../menu/presentation/menu_detail_page.dart';
import '../../orders/data/order_model.dart';
import '../../orders/presentation/order_detail_page.dart';
import '../component/home_active_order_card.dart';
import '../component/home_hero_card.dart';
import '../component/home_logo_app_bar.dart';
import '../component/home_section_header.dart';
import '../data/home_store.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onSeeAllTapped;

  const HomeView({super.key, required this.onSeeAllTapped});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const String _all = 'Semua Kopi';

  /// Jumlah menu yang ditampilkan di "Menu Favorit Tetangga" bila tanpa filter kategori.
  static const int _favoriteCount = 6;

  final MenuStore _menu = MenuStore.instance;
  final HomeStore _home = HomeStore.instance;
  String _selectedCategory = _all;

  @override
  void initState() {
    super.initState();
    _menu.addListener(_onChanged);
    _home.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _menu.load();
      _home.load();
    });
  }

  @override
  void dispose() {
    _menu.removeListener(_onChanged);
    _home.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    if (_selectedCategory != _all && !_categoryNames.contains(_selectedCategory)) {
      _selectedCategory = _all;
    }
    setState(() {});
  }

  /// Nama kategori untuk chip. Katalog menu dipakai bila sudah dimuat; selama belum,
  /// kategori dari GET /api/home supaya chip tidak kosong.
  List<String> get _categoryNames =>
      _menu.categories.isNotEmpty ? _menu.categories : _home.categories;

  List<String> get _categories => [_all, ..._categoryNames];

  /// Pesanan lunas yang sudah ditandai siap diambil oleh barista (dari GET /api/home).
  OrderModel? get _readyOrder => _home.readyOrder;

  /// Tanpa filter: menu favorit dari server. Bila /home gagal tetapi katalog sudah ada,
  /// jatuh ke enam menu pertama yang stoknya masih ada. Dengan filter: seluruh menu kategori itu.
  List<CoffeeItem> get _displayedItems {
    if (_selectedCategory == _all) {
      if (_home.status == LoadStatus.ready) return _home.favorites;
      return _menu.items.where((it) => !it.soldOut).take(_favoriteCount).toList();
    }
    return _menu.items.where((it) => it.category == _selectedCategory).toList();
  }

  /// Status muat untuk daftar yang sedang tampil.
  LoadStatus get _listStatus {
    if (_selectedCategory != _all) return _menu.status;
    if (_home.status == LoadStatus.ready || _menu.status == LoadStatus.ready) {
      return LoadStatus.ready;
    }
    if (_home.status == LoadStatus.error && _menu.status == LoadStatus.error) {
      return LoadStatus.error;
    }
    return LoadStatus.loading;
  }

  String get _listError =>
      (_selectedCategory == _all ? _home.error : null) ??
      _menu.error ??
      'Menu belum bisa dimuat.';

  void _retry() {
    _menu.load(force: true);
    _home.load(force: true);
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

            if (_listStatus == LoadStatus.error)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      Text(
                        _listError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.bark),
                      ),
                      TextButton(
                        onPressed: _retry,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_listStatus != LoadStatus.ready)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.espresso),
                  ),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_filter_chips.dart';
import '../../../core/widgets/app_menu_card.dart';
import '../../../core/widgets/app_notification.dart';
import '../../menu/data/coffee_item_model.dart';
import '../../menu/presentation/add_to_cart_bottom_sheet.dart';
import '../../orders/data/order_model.dart';
import '../../orders/presentation/order_detail_page.dart';

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

/// Kartu status pesanan aktif ("Siap Diambil").
class HomeActiveOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onAmbilTapped;

  const HomeActiveOrderCard({
    super.key,
    required this.order,
    this.onAmbilTapped,
  });

  String get _itemsSummary {
    if (order.items.isEmpty) return order.batchName;
    final first = order.items.first;
    final items = '${first.qty}× ${first.name}';
    if (order.batchName.isEmpty) return items;
    return '$items • ${order.batchName}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.statusBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD7CC)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF435436),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Siap Diambil',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF435436),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCD6CC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${order.id}',
                        style: const TextStyle(
                          color: Color(0xFF5A5248),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _itemsSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5A5248),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAmbilTapped,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.buttonDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Ambil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner utama berisi sapaan, tagline, dan tombol aksi.
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key});

  void _onContactSeller(BuildContext context) {
    AppNotification.contactSeller(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.heroBrown,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & 100% Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x40000000),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Haloo Pelanggan 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC4A482),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        '100% Kopi Asli & Aren',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFDCC8B4),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Title
          const Text(
            'yapp coffee',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Seduhan kopi berkarakter dengan harga bersahabat dan racikan khas Nusantara.',
            style: TextStyle(
              fontSize: 12.2,
              color: Color(0xFFD8C3AF),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Dashed Divider
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: const _DashedLinePainter(color: Color(0x38FFFFFF)),
          ),
          const SizedBox(height: 14),

          // Action Buttons: "Hubungi Penjual" & "@yappcoffee"
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onContactSeller(context),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBE6DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Color(0xFF2B180D),
                          size: 17,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Hubungi Penjual',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF2B180D),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x28000000),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x35FFFFFF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '@yappcoffee',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Baris logo di bagian paling atas halaman Home.
class HomeLogoAppBar extends StatelessWidget {
  const HomeLogoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
      child: Row(
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            height: 28,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

/// Judul section dengan tombol "Lihat Semua" di sisi kanan.
class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTapped;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.onActionTapped,
    this.actionLabel = 'Lihat Semua',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onActionTapped,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7B5539),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/external_links.dart';
import '../../../core/widgets/app_notification.dart';
import '../component/order_detail_top_bar.dart';
import '../component/order_items_summary_card.dart';
import '../component/order_status_tracker.dart';
import '../component/pickup_info_card.dart';
import '../component/pickup_map_card.dart';
import '../data/order_model.dart';
import '../data/order_store.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderStore _store = OrderStore.instance;
  late OrderModel _order = widget.order;

  @override
  void initState() {
    super.initState();
    _store.addListener(_syncFromStore);
    // Status dapur bisa sudah berubah sejak daftar pesanan dimuat.
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.load());
  }

  @override
  void dispose() {
    _store.removeListener(_syncFromStore);
    super.dispose();
  }

  /// Ikuti pesanan yang sama di OrderStore supaya status di halaman ini ikut berubah.
  void _syncFromStore() {
    final latest = _store.findById(widget.order.id);
    if (latest != null && mounted) setState(() => _order = latest);
  }

  Future<void> _openMaps() async {
    AppNotification.openMaps(context);
    final opened = await openExternalUrl(_order.mapsLink);
    if (!opened && mounted) {
      AppNotification.error(
        context,
        'Google Maps tidak bisa dibuka. Coba lagi atau gunakan aplikasi peta lain.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.espresso,
          onRefresh: _store.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                OrderDetailTopBar(
                  orderId: order.id,
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 16),
                OrderStatusTracker(status: order.status),
                const SizedBox(height: 14),
                OrderItemsSummaryCard(order: order),
                const SizedBox(height: 14),
                PickupInfoCard(order: order),
                const SizedBox(height: 14),
                PickupMapCard(
                  routeGuide: order.routeGuide,
                  latitude: order.latitude,
                  longitude: order.longitude,
                  onOpenMaps: _openMaps,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Harap sebutkan nama atau nomor pesanan saat\npengambilan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

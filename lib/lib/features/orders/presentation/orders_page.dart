import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../menu/data/menu_store.dart' show LoadStatus;
import '../../payment/presentation/payment_page.dart';
import '../component/active_order_card.dart';
import '../component/history_order_card.dart';
import '../component/orders_header.dart';
import '../component/orders_tab_switcher.dart';
import '../data/order_model.dart';
import '../data/order_store.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderStore _store = OrderStore.instance;
  int _tabIndex = 0; // 0 = Pesanan Aktif, 1 = Riwayat

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.load());
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  List<OrderModel> get _orders => _tabIndex == 0 ? _store.active : _store.history;

  void _open(OrderModel order) {
    // Pesanan yang belum dibayar dilanjutkan ke halaman pembayaran.
    final Widget page = order.status == OrderStatus.belumDibayar
        ? PaymentPage(order: order)
        : OrderDetailPage(order: order);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Widget _body() {
    final orders = _orders;

    if (_store.status == LoadStatus.error && orders.isEmpty) {
      return AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Pesanan belum bisa dimuat',
        message: _store.error,
        actionLabel: 'Coba Lagi',
        onAction: _store.load,
      );
    }
    if (_store.status != LoadStatus.ready && orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.espresso),
      );
    }

    return RefreshIndicator(
      color: AppColors.espresso,
      onRefresh: _store.load,
      child: orders.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 360,
                  child: AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: _tabIndex == 0
                        ? 'Belum ada pesanan aktif'
                        : 'Belum ada riwayat',
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _tabIndex == 0
                    ? ActiveOrderCard(order: order, onTap: () => _open(order))
                    : HistoryOrderCard(order: order);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            const OrdersHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: OrdersTabSwitcher(
                selectedIndex: _tabIndex,
                onChanged: (index) => setState(() => _tabIndex = index),
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }
}

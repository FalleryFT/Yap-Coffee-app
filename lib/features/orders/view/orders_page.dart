import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/viewmodel/load_status.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../payment/view/payment_page.dart';
import '../component/active_order_card.dart';
import '../component/history_order_card.dart';
import '../component/orders_header.dart';
import '../component/orders_tab_switcher.dart';
import '../model/order_model.dart';
import '../viewmodel/order_view_model.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderViewModel _orders = OrderViewModel.instance;
  int _tabIndex = 0; // 0 = Pesanan Aktif, 1 = Riwayat

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _orders.load());
  }

  List<OrderModel> get _visibleOrders =>
      _tabIndex == 0 ? _orders.active : _orders.history;

  void _open(OrderModel order) {
    // Pesanan yang belum dibayar dilanjutkan ke halaman pembayaran.
    final Widget page = order.status == OrderStatus.belumDibayar
        ? PaymentPage(order: order)
        : OrderDetailPage(order: order);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Widget _body() {
    final orders = _visibleOrders;

    if (_orders.status == LoadStatus.error && orders.isEmpty) {
      return AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Pesanan belum bisa dimuat',
        message: _orders.error,
        actionLabel: 'Coba Lagi',
        onAction: _orders.load,
      );
    }
    if (_orders.status != LoadStatus.ready && orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.espresso),
      );
    }

    return RefreshIndicator(
      color: AppColors.espresso,
      onRefresh: _orders.load,
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
    return ListenableBuilder(
      listenable: _orders,
      builder: (context, _) => Scaffold(
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
      ),
    );
  }
}

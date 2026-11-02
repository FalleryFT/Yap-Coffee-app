import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../component/active_order_card.dart';
import '../component/history_order_card.dart';
import '../component/orders_header.dart';
import '../component/orders_tab_switcher.dart';
import '../data/order_model.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _tabIndex = 0; // 0 = Pesanan Aktif, 1 = Riwayat

  List<OrderModel> get _activeOrders =>
      OrderData.orders.where((o) => o.isActive).toList();

  List<OrderModel> get _historyOrders =>
      OrderData.orders.where((o) => !o.isActive).toList();

  void _openDetail(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OrderDetailPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = _tabIndex == 0 ? _activeOrders : _historyOrders;

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
            Expanded(
              child: orders.isEmpty
                  ? AppEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: _tabIndex == 0
                          ? 'Belum ada pesanan aktif'
                          : 'Belum ada riwayat',
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _tabIndex == 0
                            ? ActiveOrderCard(
                                order: order,
                                onTap: () => _openDetail(order),
                              )
                            : HistoryOrderCard(order: order);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

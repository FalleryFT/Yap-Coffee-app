import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildTabSwitcher(),
            ),
            Expanded(
              child: orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _tabIndex == 0
                            ? _ActiveOrderCard(
                                order: order,
                                onTap: () => _openDetail(order),
                              )
                            : _HistoryOrderCard(order: order);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/app_emblem.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              'Pesanan Saya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE6DF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Pesanan Aktif'),
          _buildTab(1, 'Riwayat'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _tabIndex == index;
    final selectedBg = index == 0 ? AppColors.buttonDark : Colors.white;
    final selectedText = index == 0 ? Colors.white : AppColors.textDark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected && index == 1
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? selectedText : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            _tabIndex == 0 ? 'Belum ada pesanan aktif' : 'Belum ada riwayat',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu Pesanan Aktif
// ---------------------------------------------------------------------------
class _ActiveOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _ActiveOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardLine),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusChip(status: order.status),
                Text(
                  '#${order.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _infoText('Pengambilan: ${order.pickupDate}'),
            _infoText('Lokasi: ${order.pickupLocation}'),
            _infoText('Waktu : ${order.pickupTime}'),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFECE7DE)),
            const SizedBox(height: 12),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        item.imageAsset ?? 'assets/images/yap_latte.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${item.qty}× • ${item.notes ?? '-'}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFECE7DE)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                Text(
                  order.formattedTotal,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          color: AppColors.textDark,
          height: 1.3,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu Riwayat
// ---------------------------------------------------------------------------
class _HistoryOrderCard extends StatelessWidget {
  final OrderModel order;

  const _HistoryOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.dibatalkan;
    final textColor = isCancelled ? AppColors.textMuted : AppColors.textDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFFCF7F2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.dateLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: isCancelled
                          ? AppColors.textMuted
                          : AppColors.bark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.id,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              _StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFECE7DE)),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${item.qty}x ',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: item.name),
                        ],
                      ),
                      style: TextStyle(fontSize: 13.5, color: textColor),
                    ),
                  ),
                  Text(
                    formatRupiah(item.price),
                    style: TextStyle(
                      fontSize: 13,
                      color: isCancelled
                          ? AppColors.textMuted
                          : AppColors.bark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, color: Color(0xFFECE7DE)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Total Belanja',
                style: TextStyle(
                  fontSize: 13.5,
                  color: isCancelled ? AppColors.textMuted : AppColors.bark,
                ),
              ),
              Text(
                order.formattedTotal,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip Status
// ---------------------------------------------------------------------------
class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;

    switch (status) {
      case OrderStatus.belumDiambil:
        bg = const Color(0xFFF2E2D4);
        fg = AppColors.textDark;
        icon = Icons.inventory_2_outlined;
        label = 'Belum Diambil';
      case OrderStatus.belumDibayar:
        bg = const Color(0xFFFF8A8A);
        fg = AppColors.textDark;
        icon = Icons.inventory_2_outlined;
        label = 'Belum Dibayar';
      case OrderStatus.selesai:
        bg = const Color(0xFFDDE6BC);
        fg = AppColors.textDark;
        icon = Icons.check_circle_rounded;
        label = 'Selesai';
      case OrderStatus.dibatalkan:
        bg = const Color(0xFFFBDAD8);
        fg = const Color(0xFFB3261E);
        icon = Icons.cancel_rounded;
        label = 'Dibatalkan';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          (status == OrderStatus.selesai || status == OrderStatus.dibatalkan)
              ? 16
              : 6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
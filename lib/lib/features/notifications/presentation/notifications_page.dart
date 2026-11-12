import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_notification.dart';
import '../../menu/data/coffee_item_model.dart';
import '../../menu/data/menu_store.dart';
import '../../menu/presentation/menu_detail_page.dart';
import '../../orders/data/order_store.dart';
import '../../orders/presentation/order_detail_page.dart';
import '../data/notification_model.dart';
import '../data/notification_store.dart';

/// Daftar notifikasi: pesanan siap diambil dan menu baru.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationStore _store = NotificationStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.load());
  }

  @override
  void dispose() {
    _store.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _open(InboxNotification item) async {
    _store.markRead(item);

    switch (item.kind) {
      case NotificationKind.orderReady:
        final code = item.ref;
        if (code == null) return;
        var order = OrderStore.instance.findById(code);
        if (order == null) {
          await OrderStore.instance.load();
          order = OrderStore.instance.findById(code);
        }
        if (!mounted) return;
        if (order == null) {
          AppNotification.info(context, 'Pesanan $code tidak ditemukan.');
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailPage(order: order!),
          ),
        );
      case NotificationKind.newMenu:
        final menuId = item.ref;
        if (menuId == null) return;
        var menu = _findMenu(menuId);
        if (menu == null) {
          await MenuStore.instance.load(force: true);
          menu = _findMenu(menuId);
        }
        if (!mounted) return;
        if (menu == null) {
          AppNotification.info(context, 'Menu ini sudah tidak tersedia.');
          return;
        }
        await MenuDetailPage.open(context, menu);
      case NotificationKind.other:
        return;
    }
  }

  CoffeeItem? _findMenu(String id) {
    for (final menu in MenuStore.instance.items) {
      if (menu.id == id) return menu;
    }
    return null;
  }

  Widget _body() {
    final items = _store.items;

    if (_store.status == LoadStatus.error && items.isEmpty) {
      return AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Notifikasi belum bisa dimuat',
        message: _store.error,
        actionLabel: 'Coba Lagi',
        onAction: _store.load,
      );
    }
    if (_store.status != LoadStatus.ready && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.espresso),
      );
    }

    return RefreshIndicator(
      color: AppColors.espresso,
      onRefresh: _store.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (!_store.enabled) const _DisabledBanner(),
          if (items.isEmpty)
            const SizedBox(
              height: 360,
              child: AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Belum ada notifikasi',
                message:
                    'Kabar pesanan siap diambil dan menu baru akan muncul di sini.',
              ),
            )
          else
            for (final item in items) ...[
              _NotificationTile(item: item, onTap: () => _open(item)),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.espresso),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: AppColors.espresso,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (_store.unreadCount > 0)
            TextButton(
              onPressed: _store.markAllRead,
              child: const Text(
                'Tandai dibaca',
                style: TextStyle(
                  color: AppColors.espresso,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _body(),
    );
  }
}

class _DisabledBanner extends StatelessWidget {
  const _DisabledBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 18,
            color: AppColors.espresso,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Notifikasi dimatikan. Aktifkan lagi di Profil > Notifikasi '
              'untuk menerima kabar pesanan dan menu baru.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final InboxNotification item;
  final VoidCallback onTap;

  IconData get _icon => switch (item.kind) {
        NotificationKind.orderReady => Icons.shopping_bag_outlined,
        NotificationKind.newMenu => Icons.local_cafe_outlined,
        NotificationKind.other => Icons.notifications_none_rounded,
      };

  Color get _tint => switch (item.kind) {
        NotificationKind.orderReady => const Color(0xFFDDE6BC),
        NotificationKind.newMenu => const Color(0xFFF2E2D4),
        NotificationKind.other => const Color(0xFFF1ECE4),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        color: item.read ? Colors.white : const Color(0xFFFFFBF5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: _tint, shape: BoxShape.circle),
              child: Icon(_icon, size: 21, color: AppColors.textDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: item.read ? FontWeight.w600 : FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.bark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.timeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.read)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

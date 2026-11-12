import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../../cart/data/cart_manager.dart';
import '../../cart/presentation/cart_page.dart';
import '../../menu/data/menu_store.dart';
import '../../notifications/data/notification_model.dart';
import '../../notifications/data/notification_store.dart';
import '../../orders/data/order_store.dart';
import '../../menu/presentation/menu_page.dart';
import '../../orders/presentation/orders_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../component/floating_cart_button.dart';
import '../component/main_bottom_nav_bar.dart';
import '../data/home_store.dart';
import 'home_view.dart';

class MainShellPage extends StatefulWidget {
  final int initialIndex;

  const MainShellPage({super.key, this.initialIndex = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage>
    with WidgetsBindingObserver {
  late int _currentIndex = widget.initialIndex;
  final CartManager _cartManager = CartManager.instance;
  final NotificationStore _notifications = NotificationStore.instance;
  StreamSubscription<InboxNotification>? _arrivalSub;

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
    WidgetsBinding.instance.addObserver(this);
    _arrivalSub = _notifications.arrivals.listen(_onNotificationArrived);
    _notifications.startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _arrivalSub?.cancel();
    _notifications.stopPolling();
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  /// Polling hanya berjalan saat aplikasi terbuka; begitu dibuka kembali langsung memuat.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notifications.startPolling();
    } else if (state == AppLifecycleState.paused) {
      _notifications.stopPolling();
    }
  }

  /// Notifikasi baru dari server: tampilkan banner, lalu segarkan data yang terkait.
  void _onNotificationArrived(InboxNotification item) {
    if (!mounted) return;
    AppNotification.show(
      context,
      title: item.title,
      message: item.body,
      type: item.kind == NotificationKind.orderReady
          ? AppNotificationType.success
          : AppNotificationType.info,
      duration: const Duration(seconds: 5),
    );

    switch (item.kind) {
      case NotificationKind.orderReady:
        OrderStore.instance.load();
        HomeStore.instance.load(force: true);
      case NotificationKind.newMenu:
        MenuStore.instance.load(force: true);
        HomeStore.instance.load(force: true);
      case NotificationKind.other:
        break;
    }
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    // Status pesanan bisa berubah di sisi barista; segarkan saat tab terkait dibuka.
    if (index == 0 || index == 2) OrderStore.instance.load();
    if (index == 0) HomeStore.instance.load(force: true);
  }

  void _switchToMenu() {
    setState(() => _currentIndex = 1);
  }

  void _openCartPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeView(onSeeAllTapped: _switchToMenu),
              MenuPage(onCartTapped: _openCartPage),
              const OrdersPage(),
              const ProfilePage(),
            ],
          ),

          // Floating Cart Button (shown on Home and Menu screens only when plus has been tapped)
          if ((_currentIndex == 0 || _currentIndex == 1) &&
              _cartManager.isCartButtonVisible)
            Positioned(
              right: 18,
              bottom: 80,
              child: FloatingCartButton(
                itemCount: _cartManager.totalItemCount,
                onTap: _openCartPage,
              ),
            ),
        ],
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}

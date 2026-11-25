import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_notification.dart';
import '../../cart/view/cart_page.dart';
import '../../cart/viewmodel/cart_view_model.dart';
import '../../menu/view/menu_page.dart';
import '../../menu/viewmodel/menu_view_model.dart';
import '../../notifications/model/notification_model.dart';
import '../../notifications/viewmodel/notification_view_model.dart';
import '../../orders/viewmodel/order_view_model.dart';
import '../../orders/view/orders_page.dart';
import '../../profile/view/profile_page.dart';
import '../component/floating_buttons_layer.dart';
import '../component/main_bottom_nav_bar.dart';
import '../viewmodel/home_view_model.dart';
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
  final CartViewModel _cart = CartViewModel.instance;
  final NotificationViewModel _notifications = NotificationViewModel.instance;
  StreamSubscription<InboxNotification>? _arrivalSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _arrivalSub = _notifications.arrivals.listen(_onNotificationArrived);
    _notifications.startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _arrivalSub?.cancel();
    _notifications.stopPolling();
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
        OrderViewModel.instance.load();
        HomeViewModel.instance.load(force: true);
      case NotificationKind.newMenu:
        MenuViewModel.instance.load(force: true);
        HomeViewModel.instance.load(force: true);
      case NotificationKind.other:
        break;
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    // Status pesanan bisa berubah di sisi barista; segarkan saat tab terkait dibuka.
    if (index == 0 || index == 2) OrderViewModel.instance.load();
    if (index == 0) HomeViewModel.instance.load(force: true);
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
      body: ListenableBuilder(
        listenable: _cart,
        builder: (context, _) => Stack(
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

            // Tombol keranjang (hanya Home dan Menu, setelah tombol plus
            // ditekan) dan tombol chat AI (semua tab utama). Batas atasnya
            // mengikuti tinggi header tab yang sedang aktif. Halaman detail
            // yang di-push menutupi shell ini, sehingga tombolnya otomatis
            // hilang di sana.
            FloatingButtonsLayer(
              showCart: (_currentIndex == 0 || _currentIndex == 1) &&
                  _cart.isCartButtonVisible,
              cartItemCount: _cart.totalItemCount,
              onCartTap: _openCartPage,
              topReserved: AppHeaderMetrics.forTab(_currentIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
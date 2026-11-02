import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../cart/data/cart_manager.dart';
import '../../cart/presentation/cart_page.dart';
import '../../menu/presentation/menu_page.dart';
import '../../orders/presentation/orders_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../component/floating_cart_button.dart';
import '../component/main_bottom_nav_bar.dart';
import 'home_view.dart';

class MainShellPage extends StatefulWidget {
  final int initialIndex;

  const MainShellPage({super.key, this.initialIndex = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex = widget.initialIndex;
  final CartManager _cartManager = CartManager.instance;

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
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

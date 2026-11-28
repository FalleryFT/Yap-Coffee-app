import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Bottom navigation bar utama aplikasi (Home, Menu, Orders, Profile).
class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEDE9E2), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 8,
      ),
      // Expanded: keempat tab berbagi lebar layar, jadi label yang lebih lebar
      // (karena font perangkat besar) tidak mendorong tab lain keluar layar.
      child: Row(
        children: [
          Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home')),
          Expanded(child: _buildNavItem(1, Icons.coffee_rounded, 'Menu')),
          Expanded(
            child: _buildNavItem(2, Icons.receipt_long_outlined, 'Orders'),
          ),
          Expanded(
            child: _buildNavItem(3, Icons.person_outline_rounded, 'Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.buttonDark : const Color(0xFF6B655C);

    return InkWell(
      onTap: () => onTabTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.buttonDark : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

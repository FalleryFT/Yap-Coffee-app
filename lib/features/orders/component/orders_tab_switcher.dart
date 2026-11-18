import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Pilihan tab "Pesanan Aktif" dan "Riwayat".
class OrdersTabSwitcher extends StatelessWidget {
  const OrdersTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.labels = const ['Pesanan Aktif', 'Riwayat'],
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE6DF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(child: _tab(i, labels[i])),
        ],
      ),
    );
  }

  Widget _tab(int index, String label) {
    final isSelected = selectedIndex == index;
    final selectedBg = index == 0 ? AppColors.buttonDark : Colors.white;
    final selectedText = index == 0 ? Colors.white : AppColors.textDark;

    return GestureDetector(
      onTap: () => onChanged(index),
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
    );
  }
}

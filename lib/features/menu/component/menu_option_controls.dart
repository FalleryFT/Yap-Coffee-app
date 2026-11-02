import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Pilihan ukuran gelas (Reguler / Large).
class CupSizeOption extends StatelessWidget {
  const CupSizeOption({
    super.key,
    required this.title,
    required this.detail,
    required this.iconSize,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String detail;
  final double iconSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5D39) : const Color(0xFFE5DFD4),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.coffee_rounded,
              size: iconSize,
              color: isSelected
                  ? const Color(0xFF2C190D)
                  : const Color(0xFF5E4B3E),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip tingkat manis (Normal / Less Sugar / No Sugar).
class SugarLevelChip extends StatelessWidget {
  const SugarLevelChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5D39) : const Color(0xFFE5DFD4),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textDark : const Color(0xFF3C2C20),
          ),
        ),
      ),
    );
  }
}

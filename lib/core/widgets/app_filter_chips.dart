import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Deretan chip filter yang bisa digulir horizontal (kategori menu).
class AppFilterChips extends StatelessWidget {
  const AppFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.height = 44,
    this.horizontalPadding = 20,
    this.spacing = 8,
    this.margin = const EdgeInsets.symmetric(vertical: 10),
    this.inactiveColor = Colors.white,
    this.inactiveBorderColor = const Color(0xFFDDD6CB),
    this.inactiveTextColor = const Color(0xFF382313),
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final double height;
  final double horizontalPadding;
  final double spacing;
  final EdgeInsetsGeometry margin;
  final Color inactiveColor;
  final Color inactiveBorderColor;
  final Color inactiveTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      // Chip bisa digeser dengan mouse juga (web/desktop), bukan hanya sentuhan,
      // supaya filter terakhir yang terpotong tetap bisa dijangkau.
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: const {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.invertedStylus,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.unknown,
          },
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          itemCount: categories.length,
          separatorBuilder: (_, _) => SizedBox(width: spacing),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == selectedCategory;
            return GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.chipBrown : inactiveColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.chipBrown
                        : inactiveBorderColor,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : inactiveTextColor,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

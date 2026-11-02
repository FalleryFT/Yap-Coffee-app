import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';

/// Satu baris menu pengaturan: ikon bulat, label, dan trailing.
class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    this.icon,
    this.iconWidget,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFF1ECE4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: iconWidget ??
                    (icon != null
                        ? Icon(icon, size: 22, color: AppColors.textDark)
                        : const SizedBox.shrink()),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

/// Grup menu dengan label section di atasnya.
class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.bark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          radius: 18,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }
}

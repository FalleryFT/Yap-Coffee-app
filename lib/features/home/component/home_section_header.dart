import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Judul section dengan tombol "Lihat Semua" di sisi kanan.
class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTapped;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.onActionTapped,
    this.actionLabel = 'Lihat Semua',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onActionTapped,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7B5539),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

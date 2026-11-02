import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../presentation/profile_avatar.dart';

/// Avatar besar + teks ajakan ganti foto. Ketuk untuk membuka pilihan foto.
class AvatarPickerSection extends StatelessWidget {
  const AvatarPickerSection({
    super.key,
    required this.assetPath,
    required this.imageBytes,
    required this.onTap,
  });

  final String assetPath;
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          ProfileAvatar(
            assetPath: assetPath,
            imageBytes: imageBytes,
            size: 100,
            showCameraBadge: true,
          ),
          const SizedBox(height: 12),
          const Text(
            'Ketuk untuk mengganti foto profile',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Foto profil bulat dengan bingkai peach. Bila aset tidak ada,
/// tampil ikon orang.
class ProfileAvatar extends StatelessWidget {
  final String assetPath;
  final Uint8List? imageBytes;
  final double size;
  final bool showCameraBadge;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.assetPath = 'assets/images/profile_photo.png',
    this.imageBytes,
    this.size = 76,
    this.showCameraBadge = false,
    this.onTap,
  });

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.buttonPeach,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.5,
        color: AppColors.textDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      imageWidget = Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    } else {
      imageWidget = Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }

    final avatar = Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE2C4AE), Color(0xFFC89A72)],
        ),
      ),
      child: ClipOval(
        child: imageWidget,
      ),
    );

    Widget content = avatar;
    if (showCameraBadge) {
      content = SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            avatar,
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.buttonDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cream, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
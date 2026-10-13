import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Foto profil bulat dengan bingkai peach. Bila aset tidak ada,
/// tampil ikon orang.
class ProfileAvatar extends StatelessWidget {
  final String assetPath;
  final double size;
  final bool showCameraBadge;

  const ProfileAvatar({
    super.key,
    required this.assetPath,
    this.size = 76,
    this.showCameraBadge = false,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.buttonPeach,
            child: Icon(
              Icons.person_rounded,
              size: size * 0.5,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );

    if (!showCameraBadge) return avatar;

    return SizedBox(
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
}
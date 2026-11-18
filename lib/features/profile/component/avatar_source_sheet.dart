import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';

typedef AvatarSourceCallback = void Function(ImageSource source);

/// Bottom sheet pilihan sumber foto profil. Memanggil [onPick] untuk
/// kamera/galeri, atau [onRemove] bila memilih hapus foto kustom.
Future<void> showAvatarSourceSheet(
  BuildContext context, {
  required AvatarSourceCallback onPick,
  required VoidCallback onRemove,
  required bool hasCustomAvatar,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Ubah Foto Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih foto dari galeri atau ambil foto langsung lewat kamera',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          _SheetOption(
            icon: Icons.photo_camera_rounded,
            title: 'Ambil Foto Lewat Kamera',
            subtitle: 'Gunakan kamera untuk mengambil foto baru',
            onTap: () {
              Navigator.of(ctx).pop();
              onPick(ImageSource.camera);
            },
          ),
          const SizedBox(height: 8),
          _SheetOption(
            icon: Icons.photo_library_rounded,
            title: 'Pilih dari Galeri',
            subtitle: 'Pilih foto yang tersimpan di perangkat Anda',
            onTap: () {
              Navigator.of(ctx).pop();
              onPick(ImageSource.gallery);
            },
          ),
          if (hasCustomAvatar) ...[
            const SizedBox(height: 8),
            _SheetOption(
              icon: Icons.delete_outline_rounded,
              iconBackground: const Color(0xFFFFDAD6),
              iconColor: const Color(0xFF9B1C1C),
              titleColor: const Color(0xFF9B1C1C),
              title: 'Hapus Foto Kustom',
              subtitle: 'Kembalikan ke foto profil default',
              onTap: () {
                Navigator.of(ctx).pop();
                onRemove();
              },
            ),
          ],
        ],
      ),
    ),
  );
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBackground = AppColors.cream,
    this.iconColor = AppColors.buttonDark,
    this.titleColor = AppColors.textDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconBackground;
  final Color iconColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}

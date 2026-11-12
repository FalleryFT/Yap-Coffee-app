import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../data/profile_model.dart';
import '../presentation/profile_avatar.dart';

/// Kartu identitas pengguna (avatar, nama panggilan, nama lengkap).
class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({super.key, required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 18,
      child: Row(
        children: [
          ProfileAvatar(
            assetPath: profile.avatarAsset,
            imageBytes: profile.avatarBytes,
            imageUrl: profile.avatarUrl,
            size: 76,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: Color(0xFF1DA1F2),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

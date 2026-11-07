import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_notification.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_model.dart';
import '../presentation/profile_avatar.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileModel _profile = ProfileData.dummy;
  bool _notificationOn = true;

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<ProfileModel>(
      MaterialPageRoute<ProfileModel>(
        builder: (_) => EditProfilePage(profile: _profile),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
    }
  }

  Future<void> _logout() async {
    await AuthRepository().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/app_logo.png',
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              ProfileUserCard(profile: _profile),
              const SizedBox(height: 22),
              ProfileMenuSection(
                title: 'Pengaturan Akun',
                children: [
                  ProfileMenuRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profil',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.bark,
                    ),
                    onTap: _openEditProfile,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ProfileMenuSection(
                title: 'Preferensi Aplikasi',
                children: [
                  ProfileMenuRow(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifikasi',
                    trailing: Switch(
                      value: _notificationOn,
                      onChanged: (v) => setState(() => _notificationOn = v),
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF55612E),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFD5CEBF),
                      trackOutlineColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                    ),
                    onTap: () =>
                        setState(() => _notificationOn = !_notificationOn),
                  ),
                  const Divider(
                    height: 1,
                    indent: 12,
                    endIndent: 12,
                    color: Color(0xFFECE7DE),
                  ),
                  ProfileMenuRow(
                    iconWidget: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      size: 21,
                      color: AppColors.textDark,
                    ),
                    label: 'Hubungi Penjual',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.bark,
                    ),
                    onTap: () => AppNotification.contactSeller(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ProfileLogoutButton(onPressed: _logout),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol keluar (merah lembut) di bagian bawah halaman profil.
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Keluar',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFDAD6),
          foregroundColor: const Color(0xFF9B1C1C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

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

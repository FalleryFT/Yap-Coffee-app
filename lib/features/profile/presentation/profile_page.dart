import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_model.dart';
import 'edit_profile_page.dart';
import 'profile_avatar.dart';

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

  void _contactSeller() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Membuka WhatsApp penjual...'),
        backgroundColor: AppColors.buttonDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
              _buildUserCard(),
              const SizedBox(height: 22),
              _sectionLabel('Pengaturan Akun'),
              const SizedBox(height: 8),
              _buildCard(
                children: [
                  _MenuRow(
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
              _sectionLabel('Preferensi Aplikasi'),
              const SizedBox(height: 8),
              _buildCard(
                children: [
                  _MenuRow(
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
                  _MenuRow(
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
                    onTap: _contactSeller,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _logout,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          ProfileAvatar(
            assetPath: _profile.avatarAsset,
            imageBytes: _profile.avatarBytes,
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
                        _profile.displayName,
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
                  _profile.fullName,
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

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.bark,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: _cardDecoration(),
      child: Column(children: children),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.cardLine),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  const _MenuRow({
    this.icon,
    this.iconWidget,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

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
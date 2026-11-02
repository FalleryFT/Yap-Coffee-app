import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../../auth/data/auth_repository.dart';
import '../component/profile_logout_button.dart';
import '../component/profile_menu_section.dart';
import '../component/profile_user_card.dart';
import '../data/profile_model.dart';
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

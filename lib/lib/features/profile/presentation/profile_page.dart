import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_notification.dart';
import '../../auth/data/auth_repository.dart';
import '../../home/data/store_links.dart';
import '../../notifications/data/notification_store.dart';
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
  ProfileModel? _profile;
  String? _error;
  final NotificationStore _notifications = NotificationStore.instance;

  @override
  void initState() {
    super.initState();
    _notifications.addListener(_onNotificationsChanged);
    // Saklar menampilkan nilai dari server; muat bila layar utama belum sempat memuatnya.
    _notifications.load();
    _load();
  }

  @override
  void dispose() {
    _notifications.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  /// Menyimpan saklar Notifikasi ke server. Bila gagal, saklar kembali ke nilai semula.
  Future<void> _setNotifications(bool value) async {
    try {
      await _notifications.setEnabled(value);
      if (!mounted) return;
      AppNotification.success(
        context,
        value ? 'Notifikasi diaktifkan.' : 'Notifikasi dimatikan.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      AppNotification.error(context, e.message);
    }
  }

  Future<void> _load() async {
    if (_error != null) setState(() => _error = null);
    try {
      final user = await AuthRepository().me();
      if (!mounted) return;
      setState(() => _profile = ProfileModel.fromUser(user));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _openEditProfile() async {
    final current = _profile;
    if (current == null) return;
    final updated = await Navigator.of(context).push<ProfileModel>(
      MaterialPageRoute<ProfileModel>(
        builder: (_) => EditProfilePage(profile: current),
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
    final profile = _profile;
    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: _error == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.espresso),
                )
              : AppEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Profil belum bisa dimuat',
                  message: _error,
                  actionLabel: 'Coba Lagi',
                  onAction: _load,
                ),
        ),
      );
    }

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
              ProfileUserCard(profile: profile),
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
                      value: _notifications.enabled,
                      onChanged: _setNotifications,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF55612E),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFD5CEBF),
                      trackOutlineColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                    ),
                    onTap: () => _setNotifications(!_notifications.enabled),
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
                    onTap: () => StoreLinks.openWhatsapp(context),
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

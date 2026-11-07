import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_notification.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_submit_mixin.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/profile_model.dart';
import '../presentation/profile_avatar.dart';
import 'change_password_page.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileModel profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with FormSubmitMixin<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.fullName);
  late final TextEditingController _phone =
      TextEditingController(text: widget.profile.phone);
  late final TextEditingController _email =
      TextEditingController(text: widget.profile.email);
  late Uint8List? _avatarBytes = widget.profile.avatarBytes;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (mounted) {
          setState(() {
            _avatarBytes = bytes;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(context, 'Gagal mengambil gambar: $e');
      }
    }
  }

  void _showImagePickerOptions() {
    showAvatarSourceSheet(
      context,
      hasCustomAvatar: _avatarBytes != null,
      onPick: _pickImage,
      onRemove: () => setState(() => _avatarBytes = null),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await submit(() async {
      // TODO: sambungkan ke endpoint update profil di backend.
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });

    if (ok && mounted) {
      AppNotification.success(context, 'Profil berhasil diperbarui.');
      Navigator.of(context).pop(
        widget.profile.copyWith(
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          avatarBytes: _avatarBytes,
          clearAvatarBytes: _avatarBytes == null,
        ),
      );
    }
  }

  void _openChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChangePasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              AppPageHeader(
                title: 'Edit Profile',
                icon: Icons.person_outline_rounded,
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 20),
              AvatarPickerSection(
                assetPath: widget.profile.avatarAsset,
                imageBytes: _avatarBytes,
                onTap: _showImagePickerOptions,
              ),
              const SizedBox(height: 22),
              EditProfileFormCard(
                formKey: _formKey,
                name: _name,
                phone: _phone,
                email: _email,
                serverError: serverError,
                clearServerError: clearServerError,
              ),
              const SizedBox(height: 14),
              SecurityAccountCard(
                joinedLabel: widget.profile.joinedLabel,
                passwordUpdatedLabel: widget.profile.passwordUpdatedLabel,
                onChangePassword: _openChangePassword,
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Simpan Perubahan',
                loading: loading,
                onPressed: _save,
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: loading ? null : () => Navigator.of(context).pop(),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

/// Kartu formulir data diri pada halaman edit profil.
class EditProfileFormCard extends StatelessWidget {
  const EditProfileFormCard({
    super.key,
    required this.formKey,
    required this.name,
    required this.phone,
    required this.email,
    required this.serverError,
    required this.clearServerError,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final String? Function(String field) serverError;
  final void Function(String field) clearServerError;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 20,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            AppTextField(
              label: 'Nama Lengkap',
              controller: name,
              hint: 'Masukkan nama lengkap',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (v) => Validators.notEmpty(v, 'Nama lengkap'),
              errorText: serverError('name'),
              onChanged: (_) => clearServerError('name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Nomor Handphone / WhatsApp',
              controller: phone,
              hint: '0812 3456 7890',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: Validators.phone,
              errorText: serverError('phone'),
              onChanged: (_) => clearServerError('phone'),
              labelAction: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6BC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: Color(0xFF435436),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Terverifikasi',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF435436),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Alamat Email',
              controller: email,
              hint: 'nama@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              errorText: serverError('email'),
              onChanged: (_) => clearServerError('email'),
            ),
            const SizedBox(height: 8),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Digunakan untuk konfirmasi pesanan dan struk digital',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu "Keamanan & Akun": status keanggotaan + pintasan ganti sandi.
class SecurityAccountCard extends StatelessWidget {
  const SecurityAccountCard({
    super.key,
    required this.joinedLabel,
    required this.passwordUpdatedLabel,
    required this.onChangePassword,
  });

  final String joinedLabel;
  final String passwordUpdatedLabel;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keamanan & Akun',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1ECE4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFDCC2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Keanggotaan',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        joinedLabel,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: Color(0xFF55612E),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onChangePassword,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1ECE4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6E0D6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 22,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ganti Kata Sandi',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          passwordUpdatedLabel,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.bark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

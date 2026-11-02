import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/form_submit_mixin.dart';
import '../../../core/widgets/primary_button.dart';
import '../component/avatar_picker_section.dart';
import '../component/avatar_source_sheet.dart';
import '../component/edit_profile_form_card.dart';
import '../component/security_account_card.dart';
import '../data/profile_model.dart';
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

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../component/avatar_picker_section.dart';
import '../component/avatar_source_sheet.dart';
import '../component/edit_profile_form_card.dart';
import '../component/security_account_card.dart';
import '../model/profile_model.dart';
import '../viewmodel/profile_view_model.dart';
import 'change_password_page.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileModel profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.fullName);
  late final TextEditingController _phone =
      TextEditingController(text: widget.profile.phone);
  late final TextEditingController _email =
      TextEditingController(text: widget.profile.email);
  late Uint8List? _avatarBytes = widget.profile.avatarBytes;
  late final String? _avatarUrl = widget.profile.avatarUrl;

  /// Foto yang baru dipilih dan belum diunggah; null bila tidak ada perubahan.
  Uint8List? _pickedBytes;
  bool _removeAvatar = false;
  late String _passwordLabel = widget.profile.passwordUpdatedLabel;

  final ProfileViewModel _profile = ProfileViewModel();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _profile.dispose();
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
            _pickedBytes = bytes;
            _removeAvatar = false;
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
      hasCustomAvatar:
          _avatarBytes != null || (_avatarUrl != null && !_removeAvatar),
      onPick: _pickImage,
      onRemove: () => setState(() {
        _avatarBytes = null;
        _pickedBytes = null;
        _removeAvatar = true;
      }),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final updated = await _profile.save(
      current: widget.profile,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      avatarBytes: _avatarBytes,
      pickedAvatar: _pickedBytes,
      removeAvatar: _removeAvatar,
      avatarUrl: _avatarUrl,
      passwordLabel: _passwordLabel,
    );
    if (!mounted) return;

    final error = _profile.errorMessage;
    if (error != null) AppNotification.error(context, error);
    if (updated != null) {
      AppNotification.success(context, 'Profil berhasil diperbarui.');
      Navigator.of(context).pop(updated);
    }
  }

  Future<void> _openChangePassword() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const ChangePasswordPage()),
    );
    if (changed == true && mounted) {
      setState(() => _passwordLabel = 'Terakhir diperbarui baru saja');
    }
  }

  /// Tombol kembali di pojok kanan atas; header tetap terlihat saat form di-scroll.
  Widget _backAction() {
    return Semantics(
      button: true,
      label: 'Kembali',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _profile.loading ? null : () => Navigator.of(context).pop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardLine),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 22,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _profile,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: AppPageHeader(
                  title: 'Edit Profile',
                  icon: Icons.person_outline_rounded,
                  onBack: () => Navigator.of(context).pop(),
                  trailing: _backAction(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    children: [
                      AvatarPickerSection(
                        assetPath: widget.profile.avatarAsset,
                        imageBytes: _avatarBytes,
                        imageUrl: _removeAvatar ? null : _avatarUrl,
                        onTap: _showImagePickerOptions,
                      ),
                      const SizedBox(height: 22),
                      EditProfileFormCard(
                        formKey: _formKey,
                        name: _name,
                        phone: _phone,
                        email: _email,
                        serverError: _profile.serverError,
                        clearServerError: _profile.clearServerError,
                      ),
                      const SizedBox(height: 14),
                      SecurityAccountCard(
                        joinedLabel: widget.profile.joinedLabel,
                        passwordUpdatedLabel: _passwordLabel,
                        onChangePassword: _openChangePassword,
                      ),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: 'Simpan Perubahan',
                        loading: _profile.loading,
                        onPressed: _save,
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: _profile.loading
                            ? null
                            : () => Navigator.of(context).pop(),
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
            ],
          ),
        ),
      ),
    );
  }
}
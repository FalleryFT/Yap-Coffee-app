import 'dart:typed_data';

import '../../../core/config/api_config.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/utils/validators.dart';
import '../../auth/data/auth_models.dart';

class ProfileModel {
  final String fullName;
  final String phone;
  final String email;
  final String joinedLabel;
  final String passwordUpdatedLabel;
  final String avatarAsset;
  final Uint8List? avatarBytes;

  /// Alamat foto profil di server; null = foto bawaan aplikasi.
  final String? avatarUrl;

  const ProfileModel({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.joinedLabel,
    required this.passwordUpdatedLabel,
    this.avatarAsset = 'assets/images/profile_photo.png',
    this.avatarBytes,
    this.avatarUrl,
  });

  /// Dari GET /api/me. Foto profil tersimpan di server (`avatar`).
  factory ProfileModel.fromUser(UserProfile user, {Uint8List? avatarBytes}) {
    final phone = user.phone;
    return ProfileModel(
      fullName: user.name,
      phone: phone == null || phone.isEmpty ? '' : '0${Validators.phoneDigits(phone)}',
      email: user.email,
      joinedLabel: DateLabels.joined(user.createdAt),
      passwordUpdatedLabel: DateLabels.passwordUpdated(user.passwordUpdatedAt),
      avatarBytes: avatarBytes,
      avatarUrl: user.avatar == null ? null : ApiConfig.avatarUrl(user.avatar!),
    );
  }

  /// Nama panggilan = kata pertama dari nama lengkap.
  String get displayName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.first;
  }

  ProfileModel copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? passwordUpdatedLabel,
    String? avatarAsset,
    Uint8List? avatarBytes,
    bool clearAvatarBytes = false,
    String? avatarUrl,
    bool clearAvatarUrl = false,
  }) {
    return ProfileModel(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      joinedLabel: joinedLabel,
      passwordUpdatedLabel: passwordUpdatedLabel ?? this.passwordUpdatedLabel,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      avatarBytes: clearAvatarBytes ? null : (avatarBytes ?? this.avatarBytes),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
    );
  }
}

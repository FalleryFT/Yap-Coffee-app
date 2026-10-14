import 'dart:typed_data';

class ProfileModel {
  final String fullName;
  final String phone;
  final String email;
  final String joinedLabel;
  final String passwordUpdatedLabel;
  final String avatarAsset;
  final Uint8List? avatarBytes;

  const ProfileModel({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.joinedLabel,
    required this.passwordUpdatedLabel,
    this.avatarAsset = 'assets/images/profile_photo.png',
    this.avatarBytes,
  });

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
  }) {
    return ProfileModel(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      joinedLabel: joinedLabel,
      passwordUpdatedLabel: passwordUpdatedLabel ?? this.passwordUpdatedLabel,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      avatarBytes: clearAvatarBytes ? null : (avatarBytes ?? this.avatarBytes),
    );
  }
}

class ProfileData {
  ProfileData._();

  static const ProfileModel dummy = ProfileModel(
    fullName: 'Raka Pratama',
    phone: '0812 3456 7890',
    email: 'raka.pratama@email.com',
    joinedLabel: 'Bergabung sejak Oktober 2024',
    passwordUpdatedLabel: 'Terakhir diperbarui 2 bulan lalu',
  );
}
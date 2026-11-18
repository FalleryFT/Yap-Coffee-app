class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
    this.passwordUpdatedAt,
    this.avatar,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;

  /// Hanya terisi dari GET /api/me dan PUT /api/me.
  final String? createdAt;
  final String? passwordUpdatedAt;

  /// Nama berkas foto profil di server (/uploads/avatars/<berkas>); null = foto bawaan.
  final String? avatar;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] as String?,
      passwordUpdatedAt: json['passwordUpdatedAt'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final UserProfile user;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

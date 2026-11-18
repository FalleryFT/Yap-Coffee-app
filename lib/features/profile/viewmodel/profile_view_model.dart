import 'package:flutter/foundation.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../model/profile_model.dart';

/// State profil pengguna beserta aksi edit profil, ganti sandi, dan keluar.
/// Halaman hanya menampilkan state ini lalu mengurus navigasi dan snackbar.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    ProfileRepository? repository,
    AuthRepository? authRepository,
  })  : _repository = repository ?? ProfileRepository(),
        _authRepository = authRepository ?? AuthRepository();

  final ProfileRepository _repository;
  final AuthRepository _authRepository;

  ProfileModel? profile;
  String? error;

  bool loading = false;
  Map<String, List<String>> fieldErrors = const {};

  /// Pesan galat umum (tanpa galat per kolom) untuk ditampilkan halaman sebagai snackbar.
  String? errorMessage;

  /// Galat server untuk [field], atau null bila tidak ada.
  String? serverError(String field) {
    final list = fieldErrors[field];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  /// Hapus galat server sebuah kolom begitu pengguna mulai mengetik ulang.
  void clearServerError(String field) {
    if (!fieldErrors.containsKey(field)) return;
    fieldErrors = Map<String, List<String>>.of(fieldErrors)..remove(field);
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    loading = true;
    fieldErrors = const {};
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on ApiException catch (e) {
      fieldErrors = e.fieldErrors;
      errorMessage = e.fieldErrors.isEmpty ? e.message : null;
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Memuat profil dari GET /api/me.
  Future<void> load() async {
    if (error != null) {
      error = null;
      notifyListeners();
    }
    try {
      final user = await _authRepository.me();
      profile = ProfileModel.fromUser(user);
      notifyListeners();
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
    }
  }

  /// Profil terbaru hasil halaman Edit Profil, dipakai agar halaman Profil ikut berubah.
  void applyUpdated(ProfileModel updated) {
    profile = updated;
    notifyListeners();
  }

  /// Menyimpan nama, nomor, dan perubahan foto. Mengembalikan profil terbaru,
  /// atau null bila gagal.
  Future<ProfileModel?> save({
    required ProfileModel current,
    required String name,
    required String phone,
    Uint8List? avatarBytes,
    Uint8List? pickedAvatar,
    required bool removeAvatar,
    required String? avatarUrl,
    required String passwordLabel,
  }) async {
    // Alamat foto setelah disimpan; dibawa kembali ke halaman Profil.
    String? savedAvatarUrl = removeAvatar ? null : avatarUrl;

    final ok = await _run(() async {
      // Email tidak dikirim: perubahan email perlu verifikasi tersendiri.
      await _repository.update(name: name, phone: phone);

      if (pickedAvatar != null) {
        final user = await _repository.uploadAvatar(pickedAvatar);
        savedAvatarUrl =
            user.avatar == null ? null : ApiConfig.avatarUrl(user.avatar!);
      } else if (removeAvatar && avatarUrl != null) {
        await _repository.removeAvatar();
        savedAvatarUrl = null;
      }
    });

    if (!ok) return null;

    return current.copyWith(
      fullName: name,
      phone: phone,
      passwordUpdatedLabel: passwordLabel,
      avatarBytes: avatarBytes,
      clearAvatarBytes: avatarBytes == null,
      avatarUrl: savedAvatarUrl,
      clearAvatarUrl: savedAvatarUrl == null,
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _run(
      () => _repository.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }

  /// Menghapus sesi di perangkat dan data milik pengguna sebelumnya.
  Future<void> logout() => _authRepository.logout();
}

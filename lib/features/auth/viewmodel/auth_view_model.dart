import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';

/// State dan aksi autentikasi: masuk, daftar, OTP, dan ganti sandi.
/// Halaman hanya menampilkan state ini lalu mengurus navigasi dan snackbar.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthRepository? repository, this.cooldownSeconds = 60})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  /// Jeda minimal sebelum kode OTP boleh dikirim ulang.
  final int cooldownSeconds;

  bool loading = false;
  bool sendingOtp = false;

  /// Detik tersisa sebelum OTP boleh dikirim ulang; 0 berarti boleh.
  int cooldown = 0;

  Map<String, List<String>> fieldErrors = const {};

  /// Pesan galat umum (tanpa galat per kolom) untuk ditampilkan halaman sebagai snackbar.
  String? errorMessage;

  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

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

  /// Menjalankan [action] dengan status loading dan penanganan galat API.
  /// Mengembalikan true bila berhasil.
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

  Future<bool> login({required String email, required String password}) {
    return _run(() => _repository.login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) {
    return _run(
      () => _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }

  /// Kirim kode OTP ke email; bila berhasil, hitungan kirim ulang dimulai.
  Future<bool> sendOtp({required String email}) async {
    if (cooldown > 0 || sendingOtp) return false;

    sendingOtp = true;
    fieldErrors = const {};
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.sendOtp(email: email);
      _startCooldown();
      return true;
    } on ApiException catch (e) {
      fieldErrors = e.fieldErrors;
      errorMessage = e.fieldErrors.isEmpty ? e.message : null;
      return false;
    } finally {
      sendingOtp = false;
      notifyListeners();
    }
  }

  /// Verifikasi OTP; mengembalikan reset token, atau null bila gagal.
  Future<String?> verifyOtp({required String email, required String otp}) async {
    String? resetToken;
    final ok = await _run(() async {
      resetToken = await _repository.verifyOtp(email: email, otp: otp);
    });
    return ok ? resetToken : null;
  }

  Future<bool> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) {
    return _run(
      () => _repository.resetPassword(
        resetToken: resetToken,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    cooldown = cooldownSeconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      cooldown--;
      if (cooldown <= 0) {
        timer.cancel();
        cooldown = 0;
      }
      notifyListeners();
    });
  }
}

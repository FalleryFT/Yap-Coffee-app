import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_footer_link.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/form_submit_mixin.dart';
import '../../../core/widgets/otp_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/auth_repository.dart';
import 'new_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with FormSubmitMixin<ForgotPasswordPage> {
  static const int _otpLength = 4;
  static const int _cooldownSeconds = 60;

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _repo = AuthRepository();

  Timer? _timer;
  int _cooldown = 0; // detik tersisa sebelum boleh kirim OTP lagi
  bool _sending = false;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _cooldown--);
      if (_cooldown <= 0) timer.cancel();
    });
  }

  Future<void> _sendOtp() async {
    if (_cooldown > 0 || _sending) return;
    // Form hanya berisi kolom email, jadi validate() memeriksa email saja.
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      fieldErrors = const {};
    });

    try {
      await _repo.sendOtp(email: _email.text.trim());
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Kode OTP sudah dikirim. Periksa email kamu.',
        isError: false,
      );
      _startCooldown();
    } on ApiException catch (e) {
      showApiError(e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    if (_otp.text.length != _otpLength) {
      showAppSnackBar(context, 'Masukkan $_otpLength digit kode OTP.');
      return;
    }

    String? resetToken;
    final ok = await submit(() async {
      resetToken = await _repo.verifyOtp(
        email: _email.text.trim(),
        otp: _otp.text,
      );
    });

    final token = resetToken;
    if (ok && token != null && mounted) {
      Navigator.of(context).pushNamed(
        AppRoutes.newPassword,
        arguments: NewPasswordArgs(resetToken: token),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _cooldown == 0 && !_sending && !loading;

    return AuthScaffold(
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Password Recovery',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masukkan email untuk mengirim kode OTP.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: AppTextField(
              label: 'Email',
              controller: _email,
              hint: 'email@contoh.com',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              enabled: !loading,
              validator: Validators.email,
              errorText: serverError('email'),
              onChanged: (_) => clearServerError('email'),
              onFieldSubmitted: (_) => _sendOtp(),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(4),
                child: FilledButton(
                  onPressed: canSend ? _sendOtp : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.espresso,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.espresso.withValues(alpha: 0.6),
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_cooldown > 0 ? '$_cooldown dtk' : 'Send OTP'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Masukkan OTP',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          OtpInput(
            controller: _otp,
            length: _otpLength,
            enabled: !loading,
            errorText: serverError('otp'),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Verifikasi',
            loading: loading,
            onPressed: _verify,
          ),
          const SizedBox(height: 24),
          AuthFooterLink(
            prompt: 'Kode belum terkirim?',
            actionLabel:
                _cooldown > 0 ? 'Kirim ulang ($_cooldown dtk)' : 'Kirim ulang',
            onTap: canSend ? _sendOtp : null,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_footer_link.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/otp_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodel/auth_view_model.dart';
import 'new_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const int _otpLength = 4;

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _auth = AuthViewModel();

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _auth.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_auth.cooldown > 0 || _auth.sendingOtp) return;
    // Form hanya berisi kolom email, jadi validate() memeriksa email saja.
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final ok = await _auth.sendOtp(email: _email.text.trim());
    if (!mounted) return;

    if (ok) {
      showAppSnackBar(
        context,
        'Kode OTP sudah dikirim. Periksa email kamu.',
        isError: false,
      );
    }
    final error = _auth.errorMessage;
    if (error != null) showAppSnackBar(context, error);
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    if (_otp.text.length != _otpLength) {
      showAppSnackBar(context, 'Masukkan $_otpLength digit kode OTP.');
      return;
    }

    FocusScope.of(context).unfocus();
    final token = await _auth.verifyOtp(
      email: _email.text.trim(),
      otp: _otp.text,
    );
    if (!mounted) return;

    final error = _auth.errorMessage;
    if (error != null) showAppSnackBar(context, error);
    if (token != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.newPassword,
        arguments: NewPasswordArgs(resetToken: token),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _auth,
      builder: (context, _) {
        final canSend = _auth.cooldown == 0 && !_auth.sendingOtp && !_auth.loading;

        return AuthScaffold(
          showBack: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Password Recovery',
                subtitle: 'Masukkan email untuk mengirim kode OTP.',
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
                  enabled: !_auth.loading,
                  validator: Validators.email,
                  errorText: _auth.serverError('email'),
                  onChanged: (_) => _auth.clearServerError('email'),
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
                      child: _auth.sendingOtp
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _auth.cooldown > 0
                                  ? '${_auth.cooldown} dtk'
                                  : 'Send OTP',
                            ),
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
                enabled: !_auth.loading,
                errorText: _auth.serverError('otp'),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Verifikasi',
                loading: _auth.loading,
                onPressed: _verify,
              ),
              const SizedBox(height: 24),
              AuthFooterLink(
                prompt: 'Kode belum terkirim?',
                actionLabel: _auth.cooldown > 0
                    ? 'Kirim ulang (${_auth.cooldown} dtk)'
                    : 'Kirim ulang',
                onTap: canSend ? _sendOtp : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

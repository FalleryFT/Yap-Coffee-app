import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/form_submit_mixin.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/auth_repository.dart';

/// Argumen navigasi dari halaman verifikasi OTP.
class NewPasswordArgs {
  const NewPasswordArgs({required this.resetToken});

  final String resetToken;
}

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key, required this.args});

  final NewPasswordArgs args;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage>
    with FormSubmitMixin<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _repo = AuthRepository();

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await submit(
      () => _repo.resetPassword(
        resetToken: widget.args.resetToken,
        password: _password.text,
        passwordConfirmation: _confirmation.text,
      ),
    );

    if (ok && mounted) {
      showAppSnackBar(
        context,
        'Kata sandi berhasil diubah. Silakan masuk.',
        isError: false,
      );
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Buat Sandi Baru',
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
              'Masukkan sandi baru',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            PasswordField(
              label: 'Masukkan sandi baru',
              controller: _password,
              hint: 'Minimal 8 karakter',
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !loading,
              validator: Validators.newPassword,
              errorText: serverError('password'),
              onChanged: (_) => clearServerError('password'),
            ),
            const SizedBox(height: 20),
            PasswordField(
              label: 'Konfirmasi Sandi',
              controller: _confirmation,
              hint: 'Minimal 8 karakter',
              textInputAction: TextInputAction.done,
              enabled: !loading,
              validator: Validators.confirmation(_password),
              errorText: serverError('password_confirmation'),
              onChanged: (_) => clearServerError('password_confirmation'),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Ubah Sandi',
              loading: loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodel/auth_view_model.dart';

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

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _auth = AuthViewModel();

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    _auth.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final ok = await _auth.resetPassword(
      resetToken: widget.args.resetToken,
      password: _password.text,
      passwordConfirmation: _confirmation.text,
    );
    if (!mounted) return;

    final error = _auth.errorMessage;
    if (error != null) showAppSnackBar(context, error);
    if (ok) {
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
    return ListenableBuilder(
      listenable: _auth,
      builder: (context, _) => AuthScaffold(
        showBack: true,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Buat Sandi Baru',
                subtitle: 'Masukkan sandi baru',
              ),
              const SizedBox(height: 24),
              PasswordField(
                label: 'Masukkan sandi baru',
                controller: _password,
                hint: 'Minimal 8 karakter',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_auth.loading,
                validator: Validators.newPassword,
                errorText: _auth.serverError('password'),
                onChanged: (_) => _auth.clearServerError('password'),
              ),
              const SizedBox(height: 20),
              PasswordField(
                label: 'Konfirmasi Sandi',
                controller: _confirmation,
                hint: 'Minimal 8 karakter',
                textInputAction: TextInputAction.done,
                enabled: !_auth.loading,
                validator: Validators.confirmation(_password),
                errorText: _auth.serverError('password_confirmation'),
                onChanged: (_) => _auth.clearServerError('password_confirmation'),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Ubah Sandi',
                loading: _auth.loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

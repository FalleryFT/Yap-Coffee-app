import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_footer_link.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodel/auth_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthViewModel();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _auth.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final ok = await _auth.login(
      email: _email.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;
    final error = _auth.errorMessage;
    if (error != null) showAppSnackBar(context, error);
    if (ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _auth,
      builder: (context, _) => AuthScaffold(
        backgroundImage: 'assets/images/login_bg.jpg',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.peach,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_cafe,
                    size: 28,
                    color: AppColors.espresso,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const AuthHeader(
                title: 'Yap Coffee',
                subtitle: 'Selamat datang kembali, tetangga!',
                fontSize: 24,
              ),
              const SizedBox(height: 28),
              AppTextField(
                label: 'Email',
                controller: _email,
                hint: 'nama@email.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                enabled: !_auth.loading,
                validator: Validators.email,
                errorText: _auth.serverError('email'),
                onChanged: (_) => _auth.clearServerError('email'),
              ),
              const SizedBox(height: 20),
              PasswordField(
                label: 'Password',
                controller: _password,
                hint: '••••••••',
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enabled: !_auth.loading,
                validator: (v) => Validators.notEmpty(v, 'Password'),
                errorText: _auth.serverError('password'),
                onChanged: (_) => _auth.clearServerError('password'),
                onFieldSubmitted: (_) => _submit(),
                labelAction: InkWell(
                  onTap: _auth.loading
                      ? null
                      : () => Navigator.of(context)
                          .pushNamed(AppRoutes.forgotPassword),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(fontSize: 13, color: AppColors.mocha),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Masuk',
                trailingIcon: Icons.arrow_forward,
                loading: _auth.loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
              AuthFooterLink(
                prompt: 'Belum punya akun?',
                actionLabel: 'Daftar sekarang',
                onTap: _auth.loading
                    ? null
                    : () => Navigator.of(context).pushNamed(AppRoutes.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

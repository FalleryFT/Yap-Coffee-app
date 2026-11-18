import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_footer_link.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodel/auth_view_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _auth = AuthViewModel();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    _auth.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final ok = await _auth.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: Validators.toInternationalPhone(_phone.text),
      password: _password.text,
      passwordConfirmation: _confirmation.text,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Selamat Datang, Tetangga!',
                subtitle: 'Daftar sekarang untuk mulai pesan kopi favoritmu.',
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Nama Lengkap',
                controller: _name,
                hint: 'Masukkan nama kamu',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                enabled: !_auth.loading,
                validator: (v) => Validators.notEmpty(v, 'Nama lengkap'),
                errorText: _auth.serverError('name'),
                onChanged: (_) => _auth.clearServerError('name'),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Email',
                controller: _email,
                hint: 'email@contoh.com',
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
              AppTextField(
                label: 'Nomor Handphone / WhatsApp',
                controller: _phone,
                hint: '0812 3456 7890',
                icon: Icons.phone_outlined,
                prefixText: '+62',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                ],
                enabled: !_auth.loading,
                validator: Validators.phone,
                errorText: _auth.serverError('phone'),
                onChanged: (_) => _auth.clearServerError('phone'),
              ),
              const SizedBox(height: 20),
              PasswordField(
                label: 'Kata Sandi',
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
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Daftar Sekarang',
                loading: _auth.loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
              AuthFooterLink(
                prompt: 'Sudah punya akun?',
                actionLabel: 'Masuk di sini',
                onTap: _auth.loading
                    ? null
                    : () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

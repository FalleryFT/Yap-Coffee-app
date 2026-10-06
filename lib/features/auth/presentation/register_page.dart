import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_footer_link.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/form_submit_mixin.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/auth_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with FormSubmitMixin<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _repo = AuthRepository();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await submit(
      () => _repo.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: Validators.toInternationalPhone(_phone.text),
        password: _password.text,
        passwordConfirmation: _confirmation.text,
      ),
    );

    if (ok && mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selamat Datang, Tetangga!',
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
              'Daftar sekarang untuk mulai pesan kopi favoritmu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Nama Lengkap',
              controller: _name,
              hint: 'Masukkan nama kamu',
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              enabled: !loading,
              validator: (v) => Validators.notEmpty(v, 'Nama lengkap'),
              errorText: serverError('name'),
              onChanged: (_) => clearServerError('name'),
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
              enabled: !loading,
              validator: Validators.email,
              errorText: serverError('email'),
              onChanged: (_) => clearServerError('email'),
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
              enabled: !loading,
              validator: Validators.phone,
              errorText: serverError('phone'),
              onChanged: (_) => clearServerError('phone'),
            ),
            const SizedBox(height: 20),
            PasswordField(
              label: 'Kata Sandi',
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
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Daftar Sekarang',
              loading: loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
            AuthFooterLink(
              prompt: 'Sudah punya akun?',
              actionLabel: 'Masuk di sini',
              onTap: loading ? null : () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

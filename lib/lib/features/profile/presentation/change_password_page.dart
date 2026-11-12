import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_notification.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/form_submit_mixin.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/profile_repository.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with FormSubmitMixin<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await submit(() async {
      await ProfileRepository().changePassword(
        currentPassword: _oldPassword.text,
        password: _newPassword.text,
        passwordConfirmation: _confirmation.text,
      );
    });

    if (ok && mounted) {
      AppNotification.success(context, 'Kata sandi berhasil diubah.');
      Navigator.of(context).pop(true);
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
            const AuthHeader(
              title: 'Buat Sandi Baru',
              subtitle: 'Masukkan sandi lama dan sandi baru',
              fontSize: 26,
            ),
            const SizedBox(height: 24),
            PasswordField(
              label: 'Masukkan sandi lama',
              controller: _oldPassword,
              hint: 'Minimal 8 karakter',
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.password],
              validator: (v) => Validators.notEmpty(v, 'Sandi lama'),
              errorText: serverError('current_password'),
              onChanged: (_) => clearServerError('current_password'),
            ),
            const SizedBox(height: 16),
            PasswordField(
              label: 'Masukkan sandi baru',
              controller: _newPassword,
              hint: 'Minimal 8 karakter',
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.newPassword,
              errorText: serverError('password'),
              onChanged: (_) => clearServerError('password'),
            ),
            const SizedBox(height: 16),
            PasswordField(
              label: 'Confirmasi Sandi',
              controller: _confirmation,
              hint: 'Minimal 8 karakter',
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.confirmation(_newPassword),
              errorText: serverError('password_confirmation'),
              onChanged: (_) => clearServerError('password_confirmation'),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
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
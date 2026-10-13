import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/form_submit_mixin.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/primary_button.dart';

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
      // TODO: sambungkan ke endpoint ganti kata sandi di backend.
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });

    if (ok && mounted) {
      showAppSnackBar(
        context,
        'Kata sandi berhasil diubah.',
        isError: false,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Buat Sandi Baru',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.espresso,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Masukkan sandi lama dan sandi baru',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.bark,
                            ),
                          ),
                          const SizedBox(height: 24),
                          PasswordField(
                            label: 'Masukkan sandi lama',
                            controller: _oldPassword,
                            hint: 'Minimal 8 karakter',
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.password],
                            validator: (v) =>
                                Validators.notEmpty(v, 'Sandi lama'),
                            errorText: serverError('current_password'),
                            onChanged: (_) =>
                                clearServerError('current_password'),
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
                            onChanged: (_) =>
                                clearServerError('password_confirmation'),
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
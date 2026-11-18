import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';

/// Kartu formulir data diri pada halaman edit profil.
class EditProfileFormCard extends StatelessWidget {
  const EditProfileFormCard({
    super.key,
    required this.formKey,
    required this.name,
    required this.phone,
    required this.email,
    required this.serverError,
    required this.clearServerError,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final String? Function(String field) serverError;
  final void Function(String field) clearServerError;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 20,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            AppTextField(
              label: 'Nama Lengkap',
              controller: name,
              hint: 'Masukkan nama lengkap',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (v) => Validators.notEmpty(v, 'Nama lengkap'),
              errorText: serverError('name'),
              onChanged: (_) => clearServerError('name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Nomor Handphone / WhatsApp',
              controller: phone,
              hint: '0812 3456 7890',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: Validators.phone,
              errorText: serverError('phone'),
              onChanged: (_) => clearServerError('phone'),
              labelAction: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6BC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: Color(0xFF435436),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Terverifikasi',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF435436),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Alamat Email',
              controller: email,
              hint: 'nama@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              // Email tidak bisa diubah dari aplikasi (perlu verifikasi tersendiri).
              enabled: false,
              validator: Validators.email,
              errorText: serverError('email'),
              onChanged: (_) => clearServerError('email'),
            ),
            const SizedBox(height: 8),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Digunakan untuk konfirmasi pesanan dan struk digital',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

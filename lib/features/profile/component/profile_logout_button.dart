import 'package:flutter/material.dart';

/// Tombol keluar (merah lembut) di bagian bawah halaman profil.
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Keluar',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFDAD6),
          foregroundColor: const Color(0xFF9B1C1C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

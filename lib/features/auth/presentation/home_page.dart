import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

/// Halaman sementara untuk membuktikan token terkirim otomatis oleh interceptor.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = AuthRepository();
  late final Future<UserProfile> _profile = _repo.me();

  Future<void> _logout() async {
    await _repo.logout();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yap Coffee'),
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.espresso,
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<UserProfile>(
          future: _profile,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator(color: AppColors.espresso);
            }
            if (snapshot.hasError) {
              final error = snapshot.error;
              final message =
                  error is ApiException ? error.message : 'Gagal memuat profil.';
              return Text(message, textAlign: TextAlign.center);
            }
            final user = snapshot.requireData;
            return Text(
              'Halo, ${user.name}!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.espresso,
              ),
            );
          },
        ),
      ),
    );
  }
}

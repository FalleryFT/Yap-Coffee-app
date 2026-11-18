import 'package:flutter/material.dart';

import '../../notifications/component/notification_bell.dart';

/// Baris logo di bagian paling atas halaman Home, dengan lonceng notifikasi di kanan.
class HomeLogoAppBar extends StatelessWidget {
  const HomeLogoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 12, top: 4, bottom: 4),
      child: Row(
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            height: 28,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          const NotificationBell(),
        ],
      ),
    );
  }
}

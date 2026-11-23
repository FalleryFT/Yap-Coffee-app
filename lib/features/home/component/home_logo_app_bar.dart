import 'package:flutter/material.dart';

import '../../../core/widgets/app_logo.dart';
import '../../notifications/component/notification_bell.dart';

/// Baris logo di bagian paling atas halaman Home, dengan lonceng notifikasi di kanan.
class HomeLogoAppBar extends StatelessWidget {
  const HomeLogoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppHeaderMetrics.home,
      child: Padding(
        padding: EdgeInsets.only(left: 18, right: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppLogo(),
            Spacer(),
            NotificationBell(),
          ],
        ),
      ),
    );
  }
}
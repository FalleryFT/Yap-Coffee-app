import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/notification_store.dart';
import '../presentation/notifications_page.dart';

/// Ikon lonceng di Home dengan lencana jumlah notifikasi yang belum dibaca.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final store = NotificationStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final unread = store.unreadCount;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
          ),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  store.enabled
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_off_outlined,
                  size: 26,
                  color: AppColors.espresso,
                ),
                if (unread > 0)
                  Positioned(
                    top: 4,
                    right: 2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.cream, width: 1.5),
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

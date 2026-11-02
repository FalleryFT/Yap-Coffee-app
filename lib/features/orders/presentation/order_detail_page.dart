import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../component/order_detail_top_bar.dart';
import '../component/order_items_summary_card.dart';
import '../component/pickup_info_card.dart';
import '../component/pickup_map_card.dart';
import '../data/order_model.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              OrderDetailTopBar(
                orderId: order.id,
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              OrderItemsSummaryCard(order: order),
              const SizedBox(height: 14),
              PickupInfoCard(order: order),
              const SizedBox(height: 14),
              PickupMapCard(
                routeGuide: order.routeGuide,
                onOpenMaps: () => AppNotification.openMaps(context),
              ),
              const SizedBox(height: 16),
              const Text(
                'Harap sebutkan nama atau nomor pesanan saat\npengambilan di Gazebo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_notification.dart';
import '../../../core/widgets/app_order_summary_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../payment/view/payment_page.dart';
import '../component/checkout_order_card.dart';
import '../component/pickup_schedule_card.dart';
import '../viewmodel/checkout_view_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CheckoutViewModel _checkout = CheckoutViewModel();

  @override
  void initState() {
    super.initState();
    _checkout.cart.addListener(_onCartChanged);
    _checkout.loadSchedules();
  }

  @override
  void dispose() {
    _checkout.cart.removeListener(_onCartChanged);
    _checkout.dispose();
    super.dispose();
  }

  /// Keranjang yang dikosongkan dari luar (mis. keluar akun) menutup halaman ini.
  void _onCartChanged() {
    if (!mounted || _checkout.submitted) return;
    if (_checkout.items.isEmpty &&
        (ModalRoute.of(context)?.isCurrent ?? false)) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onConfirm() async {
    final order = await _checkout.submit();
    if (!mounted) return;

    final error = _checkout.errorMessage;
    if (error != null) AppNotification.error(context, error);
    if (order != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => PaymentPage(order: order)),
      );
    }
  }

  PickupDate _pickupDate(int index) {
    final label = _checkout.dateLabel(index);
    return PickupDate(label.day, label.date, label.month);
  }

  Widget _scheduleSection() {
    if (_checkout.loadingSchedules) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: AppColors.espresso)),
      );
    }
    if (_checkout.scheduleError != null) {
      return SizedBox(
        height: 260,
        child: AppEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Jadwal belum bisa dimuat',
          message: _checkout.scheduleError,
          actionLabel: 'Coba Lagi',
          onAction: _checkout.loadSchedules,
        ),
      );
    }
    if (_checkout.schedules.isEmpty) {
      return const SizedBox(
        height: 260,
        child: AppEmptyState(
          icon: Icons.event_busy_outlined,
          title: 'Belum ada jadwal pre-order',
          message: 'Jadwal pengambilan yang masih dibuka akan muncul di sini.',
        ),
      );
    }

    final onDate = _checkout.schedulesOnSelectedDate;
    final selected = _checkout.selectedSchedule;
    return PickupScheduleCard(
      dates: [
        for (var i = 0; i < _checkout.dateKeys.length; i++) _pickupDate(i),
      ],
      windows: onDate.map((s) => PickupWindow(s.windowLabel, s.name)).toList(),
      selectedDate: _checkout.selectedDate,
      selectedWindow: _checkout.clampedWindow,
      location: selected?.location ?? '',
      area: selected?.locationDetail ?? '',
      onDateSelected: _checkout.selectDate,
      onWindowSelected: _checkout.selectWindow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _checkout,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.espresso),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Checkout Pre-Order',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.espresso,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _scheduleSection(),
              const SizedBox(height: 16),
              CheckoutOrderCard(
                items: _checkout.items,
                onQuantityChanged: _checkout.updateQuantity,
                onAddMore: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              // Rincian ini perkiraan; total resmi dihitung server saat pesanan dibuat.
              OrderSummaryCard(
                rows: [
                  SummaryRow('Subtotal', rupiah(_checkout.subtotal)),
                  SummaryRow('Pajak (11%)', rupiah(_checkout.tax)),
                  SummaryRow('Biaya Layanan', rupiah(_checkout.serviceFee)),
                ],
                totalLabel: 'Total',
                totalValue: rupiah(_checkout.grandTotal),
                titleFontSize: 20,
                labelFontSize: 14,
                totalFontSize: 22,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: AppColors.cream,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SafeArea(
            top: false,
            child: PrimaryButton(
              label: 'konfirmasi pre order',
              loading: _checkout.submitting,
              onPressed: _checkout.selectedSchedule == null ? null : _onConfirm,
            ),
          ),
        ),
      ),
    );
  }
}

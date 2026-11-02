import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_order_summary_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../cart/data/cart_manager.dart';
import '../../payment/presentation/payment_page.dart';
import '../component/checkout_order_card.dart';
import '../component/pickup_schedule_card.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartManager _cartManager = CartManager.instance;

  static const List<PickupDate> _dates = [
    PickupDate('Jum', '27', 'Okt'),
    PickupDate('Sen', '30', 'Okt'),
    PickupDate('Sel', '31', 'Okt'),
    PickupDate('Rab', '01', 'Nov'),
  ];

  static const List<PickupWindow> _windows = [
    PickupWindow('08:30 - 11:30 WIB', 'Kloter Utama Pagi'),
    PickupWindow('13:00 - 15:30 WIB', 'Kloter Siang'),
  ];

  int _selectedDate = 0;
  int _selectedWindow = 0;

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (!mounted) return;
    if (_cartManager.items.isEmpty) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        Navigator.of(context).pop();
      }
      return;
    }
    setState(() {});
  }

  void _onConfirm() {
    final lines = _cartManager.items
        .map((it) => '${it.quantity}x ${it.name}')
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentPage(orderLines: lines),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            PickupScheduleCard(
              dates: _dates,
              windows: _windows,
              selectedDate: _selectedDate,
              selectedWindow: _selectedWindow,
              onDateSelected: (index) => setState(() => _selectedDate = index),
              onWindowSelected: (index) =>
                  setState(() => _selectedWindow = index),
            ),
            const SizedBox(height: 16),
            CheckoutOrderCard(
              items: _cartManager.items,
              onQuantityChanged: _cartManager.updateQuantity,
              onAddMore: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16),
            OrderSummaryCard(
              rows: [
                SummaryRow('Subtotal', rupiah(_cartManager.subtotal)),
                SummaryRow('Pajak (11%)', rupiah(_cartManager.tax)),
                SummaryRow('Biaya Layanan', rupiah(_cartManager.serviceFee)),
              ],
              totalLabel: 'Total',
              totalValue: rupiah(_cartManager.grandTotal),
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
            onPressed: _onConfirm,
          ),
        ),
      ),
    );
  }
}

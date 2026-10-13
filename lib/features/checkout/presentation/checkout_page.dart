import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../cart/data/cart_manager.dart';
import '../../orders/data/order_model.dart' show formatRupiah;
import '../../payment/presentation/payment_page.dart';

class _PickupDate {
  final String day;
  final String date;
  final String month;

  const _PickupDate(this.day, this.date, this.month);
}

class _PickupWindow {
  final String time;
  final String batch;

  const _PickupWindow(this.time, this.batch);
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartManager _cartManager = CartManager.instance;

  // Data dummy sesuai desain
  static const List<_PickupDate> _dates = [
    _PickupDate('Jum', '27', 'Okt'),
    _PickupDate('Sen', '30', 'Okt'),
    _PickupDate('Sel', '31', 'Okt'),
    _PickupDate('Rab', '01', 'Nov'),
  ];

  static const List<_PickupWindow> _windows = [
    _PickupWindow('08:30 - 11:30 WIB', 'Kloter Utama Pagi'),
    _PickupWindow('13:00 - 15:30 WIB', 'Kloter Siang'),
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
    final items = _cartManager.items;

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
            _buildScheduleCard(),
            const SizedBox(height: 16),
            _buildOrderCard(items),
            const SizedBox(height: 16),
            _buildTotalCard(),
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

  // ---------------------------------------------------------------- Card

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardLine),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(93, 58, 26, 0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  // ------------------------------------------------------ Jadwal Pengambilan

  Widget _buildScheduleCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal Pengambilan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pilih Tanggal Pre-Order',
            style: TextStyle(fontSize: 12.5, color: AppColors.bark),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _dates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _buildDateChip(index),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Jam Pengambilan (Pickup Window)',
            style: TextStyle(fontSize: 12.5, color: AppColors.bark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < _windows.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _buildWindowChip(i)),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.cardLine),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.espresso,
              ),
              SizedBox(width: 8),
              Text(
                'TITIK TEMU PENGAMBILAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.espresso,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Gedung Sipil UB – Gazebo Tengah Lantai 1',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.school_outlined, size: 16, color: AppColors.bark),
              SizedBox(width: 8),
              Text(
                'Area Kampus Universitas Brawijaya',
                style: TextStyle(fontSize: 12.5, color: AppColors.bark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(int index) {
    final data = _dates[index];
    final selected = index == _selectedDate;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = index),
      child: Container(
        width: 72,
        decoration: BoxDecoration(
          color: selected ? AppColors.espresso : AppColors.cream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.espresso : AppColors.line,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data.day,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AppColors.buttonPeach : AppColors.bark,
              ),
            ),
            Text(
              data.date,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.15,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
            Text(
              data.month,
              style: TextStyle(
                fontSize: 10.5,
                color: selected ? AppColors.buttonPeach : AppColors.mocha,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowChip(int index) {
    final data = _windows[index];
    final selected = index == _selectedWindow;

    return GestureDetector(
      onTap: () => setState(() => _selectedWindow = index),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.espresso : AppColors.cream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.espresso : AppColors.line,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data.time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.batch,
              style: TextStyle(
                fontSize: 10.5,
                color: selected ? AppColors.buttonPeach : AppColors.mocha,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------- Ringkasan Pesanan

  Widget _buildOrderCard(List<CartItem> items) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 1, color: AppColors.cardLine),
              const SizedBox(height: 14),
            ],
            _buildItemRow(items[i]),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.add_circle_outline,
                size: 24,
                color: AppColors.ink,
              ),
              label: const Text(
                'Tambah Pesanan Lain',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.espresso),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item.imageAsset,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: const Color(0xFFF0EEE9),
              child: const Icon(
                Icons.coffee_rounded,
                color: AppColors.bark,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatRupiah(item.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.variant,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, color: AppColors.bark),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStepperButton(
                    Icons.remove,
                    () => _cartManager.updateQuantity(item, -1),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  _buildStepperButton(
                    Icons.add,
                    () => _cartManager.updateQuantity(item, 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 16, color: AppColors.espresso),
      ),
    );
  }

  // ------------------------------------------------------------------ Total

  Widget _buildTotalCard() {
    return _card(
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', formatRupiah(_cartManager.subtotal)),
          const SizedBox(height: 12),
          _buildSummaryRow('Pajak (11%)', formatRupiah(_cartManager.tax)),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Biaya Layanan',
            formatRupiah(_cartManager.serviceFee),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.cardLine),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                formatRupiah(_cartManager.grandTotal),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.espresso,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.bark),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppColors.bark),
        ),
      ],
    );
  }
}
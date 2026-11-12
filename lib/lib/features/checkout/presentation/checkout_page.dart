import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_notification.dart';
import '../../../core/widgets/app_order_summary_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../cart/data/cart_manager.dart';
import '../../menu/data/menu_store.dart';
import '../../orders/data/order_store.dart';
import '../../payment/presentation/payment_page.dart';
import '../component/checkout_order_card.dart';
import '../component/pickup_schedule_card.dart';
import '../data/pickup_schedule.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartManager _cartManager = CartManager.instance;
  final ScheduleRepository _scheduleRepository = ScheduleRepository();

  List<PickupSchedule> _schedules = const [];
  bool _loadingSchedules = true;
  String? _scheduleError;

  int _selectedDate = 0;
  int _selectedWindow = 0;

  bool _submitting = false;

  /// Setelah pesanan dibuat keranjang dikosongkan; halaman ini tidak boleh menutup dirinya sendiri.
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
    _loadSchedules();
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (!mounted || _submitted) return;
    if (_cartManager.items.isEmpty) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        Navigator.of(context).pop();
      }
      return;
    }
    setState(() {});
  }

  Future<void> _loadSchedules() async {
    // Pemanggilan pertama dari initState: nilai awal sudah "memuat", jadi tidak perlu setState.
    if (!_loadingSchedules) {
      setState(() {
        _loadingSchedules = true;
        _scheduleError = null;
      });
    }
    try {
      final schedules = await _scheduleRepository.fetchOpen();
      if (!mounted) return;
      setState(() {
        _schedules = schedules;
        _selectedDate = 0;
        _selectedWindow = 0;
        _loadingSchedules = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _scheduleError = e.message;
        _loadingSchedules = false;
      });
    }
  }

  /// Tanggal unik, urut seperti dari server (sudah urut tanggal).
  List<String> get _dateKeys {
    final keys = <String>[];
    for (final s in _schedules) {
      if (!keys.contains(s.date)) keys.add(s.date);
    }
    return keys;
  }

  List<PickupDate> get _dates => _dateKeys.map((key) {
        final d = DateLabels.parse(key);
        if (d == null) return PickupDate('', key, '');
        return PickupDate(
          DateLabels.dayShort(d),
          DateLabels.dayOfMonth(d),
          DateLabels.monthShort(d),
        );
      }).toList();

  /// Kloter pada tanggal yang sedang dipilih.
  List<PickupSchedule> get _schedulesOnSelectedDate {
    final keys = _dateKeys;
    if (keys.isEmpty) return const [];
    final key = keys[_selectedDate.clamp(0, keys.length - 1)];
    return _schedules.where((s) => s.date == key).toList();
  }

  PickupSchedule? get _selectedSchedule {
    final list = _schedulesOnSelectedDate;
    if (list.isEmpty) return null;
    return list[_selectedWindow.clamp(0, list.length - 1)];
  }

  String _firstError(ApiException e) {
    for (final key in const ['items', 'scheduleId']) {
      final message = e.errorFor(key);
      if (message != null) return message;
    }
    return e.message;
  }

  Future<void> _onConfirm() async {
    final schedule = _selectedSchedule;
    if (schedule == null || _submitting) return;

    final lines = <Map<String, dynamic>>[];
    for (final item in _cartManager.items) {
      final menuId = item.originalItem?.apiId;
      if (menuId == null) {
        AppNotification.error(
          context,
          '${item.name} tidak valid. Hapus dari keranjang lalu pilih ulang.',
        );
        return;
      }
      lines.add({
        'menuItemId': menuId,
        'qty': item.quantity,
        if (item.sizeLabel != null) 'size': item.sizeLabel,
        if (item.sugarLabel != null) 'sugarLevel': item.sugarLabel,
        if (item.addons.isNotEmpty) 'addonIds': item.addonIds,
      });
    }

    setState(() => _submitting = true);
    try {
      final order = await OrderStore.instance.repository.create(
        scheduleId: schedule.id,
        items: lines,
      );
      if (!mounted) return;

      _submitted = true;
      OrderStore.instance.upsert(order);
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => PaymentPage(order: order)),
      );
      _cartManager.clearCart();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppNotification.error(context, _firstError(e));
      // Stok atau jadwal bisa berubah; segarkan agar pilihan berikutnya akurat.
      MenuStore.instance.load(force: true);
      _loadSchedules();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _scheduleSection() {
    if (_loadingSchedules) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: AppColors.espresso)),
      );
    }
    if (_scheduleError != null) {
      return SizedBox(
        height: 260,
        child: AppEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Jadwal belum bisa dimuat',
          message: _scheduleError,
          actionLabel: 'Coba Lagi',
          onAction: _loadSchedules,
        ),
      );
    }
    if (_schedules.isEmpty) {
      return const SizedBox(
        height: 260,
        child: AppEmptyState(
          icon: Icons.event_busy_outlined,
          title: 'Belum ada jadwal pre-order',
          message: 'Jadwal pengambilan yang masih dibuka akan muncul di sini.',
        ),
      );
    }

    final onDate = _schedulesOnSelectedDate;
    final selected = _selectedSchedule;
    return PickupScheduleCard(
      dates: _dates,
      windows: onDate.map((s) => PickupWindow(s.windowLabel, s.name)).toList(),
      selectedDate: _selectedDate,
      selectedWindow: _selectedWindow.clamp(0, onDate.length - 1),
      location: selected?.location ?? '',
      area: selected?.locationDetail ?? '',
      onDateSelected: (index) => setState(() {
        _selectedDate = index;
        _selectedWindow = 0;
      }),
      onWindowSelected: (index) => setState(() => _selectedWindow = index),
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
            _scheduleSection(),
            const SizedBox(height: 16),
            CheckoutOrderCard(
              items: _cartManager.items,
              onQuantityChanged: _cartManager.updateQuantity,
              onAddMore: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16),
            // Rincian ini perkiraan; total resmi dihitung server saat pesanan dibuat.
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
            loading: _submitting,
            onPressed: _selectedSchedule == null ? null : _onConfirm,
          ),
        ),
      ),
    );
  }
}
